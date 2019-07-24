require 'services/google_service'

module Models
  module Trip
    module TripRouteExtension
      extend ActiveSupport::Concern

      # ToDo: Move this to yaml file
      DEFAULT_DRIVER_CHECKIN_START_TIME = 90.minutes
      DEFAULT_DRIVER_CHECKOUT_START_TIME = 10.minutes
      PICKUP_OR_DROP_SWAP_RADIUS = 5 # in km
      ONBOARD_PASSENGER_TIME = eval(ENV["ONBOARD_PASSENGER_TIME"]) / 60
      TIME_TO_ARRIVE = 10
      DRIVER_ASSIGN_REQUEST_EXPIRATION = 3.minutes

      def is_first_female_pickup(waypoints=[])
        if waypoints.empty?
          if self.is_manual
            if self.check_in?
              waypoints = employee_trips.joins(:employee).order("route_order ASC")
            else
              waypoints = employee_trips.joins(:employee).order("route_order DESC")
            end
          else
            waypoints = employee_trips.joins(:employee).order("employees.distance_to_site DESC")
          end          
        end
        return false if waypoints.empty?
        check_in? && waypoints.first.employee&.gender == "female"
      end

      def is_last_female_drop(waypoints=[])
        if waypoints.empty?
          if self.is_manual
            if self.check_in?
              waypoints = employee_trips.joins(:employee).order("route_order ASC")
            else
              waypoints = employee_trips.joins(:employee).order("route_order DESC")
            end
          else
            waypoints = employee_trips.joins(:employee).order("employees.distance_to_site DESC")
          end
        end
        return false if waypoints.empty?
        check_out? && waypoints.last.employee&.gender == "female"
      end

      def create_or_update_route
        if self.is_manual
          if self.check_in?
            waypoints = employee_trips.joins(:employee).order("route_order ASC")
          else
            waypoints = employee_trips.joins(:employee).order("route_order DESC")
          end
        else
          waypoints = employee_trips.joins(:employee).order("employees.distance_to_site DESC")
        end       

        guard = waypoints.where("employees.is_guard =?", true)
        # waypoints = reorder_waypoints(waypoints) if is_first_female_pickup(waypoints) || is_last_female_drop(waypoints)
        waypoints = move_guard_position(waypoints.to_a, guard.first) if !guard.blank?
        waypoints = waypoints.to_a.compact
        first_waypoint = waypoints.shift
        last_waypoint = waypoints.pop if check_out? && !guard.empty?

        is_bus_trip = false
        if !first_waypoint.employee.is_guard
          is_bus_trip = first_waypoint.bus_rider
        end

        origin = site_location

        # Guard is not available for bus trip
        if !guard.empty? && check_in?
          destination = waypoints.first.home_address
        else
          destination = first_waypoint.home_address
        end

        trip_start_date = employee_trips.maximum(:date).in_time_zone(Time.zone)
        trip_start_date = check_in? ? trip_start_date - DEFAULT_DRIVER_CHECKIN_START_TIME : trip_start_date + DEFAULT_DRIVER_CHECKOUT_START_TIME
        trip_start_date = Time.now.in_time_zone(Time.zone) if trip_start_date < Time.now.in_time_zone(Time.zone)
        if !is_bus_trip
          if is_manual
            waypoints = waypoints.reverse
          end
          route = get_route(origin, destination, trip_start_date, waypoints.map{|et| et.home_address})
          reordered_waypoints = route.first[:waypoint_order].map{|i| waypoints[i]}
          reordered_waypoints.push(first_waypoint)

          route_data = route.first[:legs]

          if self.check_in?
            reordered_waypoints = reordered_waypoints.reverse
            route_data = route_data.reverse
          end
          
          last_employee_trip = []
          route_order = 0
          new_trip_routes = reordered_waypoints.each_with_index.map do |employee_trip, i|
            if last_employee_trip.present? && last_employee_trip.home_address != employee_trip.home_address
              route_order = route_order + 1
            end
            last_employee_trip = employee_trip
            start_location, end_location = check_in? ? [route_data[i][:end_location],route_data[i][:start_location]] : [route_data[i][:start_location],route_data[i][:end_location]]
            new_route_data_intr = get_route(start_location, end_location, trip_start_date).first[:legs]
            trip_route_attr = construct_trip_route_param(employee_trip, route_order, new_route_data_intr, route_data[i][:distance][:value], start_location, end_location)
            update_trip_route(employee_trip.trip_route, trip_route_attr) if employee_trip.trip_route.present? 
            trip_route_attr if employee_trip.trip_route.blank?             
          end
          new_trip_routes.compact!
          create_trip_route(new_trip_routes) unless new_trip_routes.blank?
          process_last_waypoint(last_waypoint, reordered_waypoints.last.trip_route, trip_start_date) if last_waypoint.present?
          update_trip_info          
        else
          #Fetch all the bus trip routes
          @uniq_bus_trip_routes = []
          employee_trips.each do |et|
            @uniq_bus_trip_routes.push(et.employee.bus_trip_route.id)
          end
          @bus_trip_routes = BusTripRoute.where(:id => @uniq_bus_trip_routes.uniq).order('stop_order asc')

          #Convert bus trip routes to an array of objects
          bus_trip_array = @bus_trip_routes.to_a

          destination = bus_trip_array.first.bus_trip_location
          first_bus_trip = bus_trip_array.shift
          bus_trip_array = bus_trip_array.reverse

          route = get_bus_route(origin, destination, trip_start_date, bus_trip_array.map{|bt| bt.bus_trip_location})

          reordered_bus_points = route.first[:waypoint_order].map{|i| bus_trip_array[i]}
          reordered_bus_points.push(first_bus_trip)
          route_data = route.first[:legs]

          if self.check_in?
            reordered_bus_points = reordered_bus_points.reverse
            route_data = route_data.reverse
          end

          route_order = 0
          new_trip_routes = reordered_bus_points.each_with_index.map do |bus_point, i|
            trip_array = []
            employee_trips.each do |et|             
              if et.employee.bus_trip_route.id == bus_point.id             
                start_location, end_location = check_in? ? [route_data[i][:end_location],route_data[i][:start_location]] : [route_data[i][:start_location],route_data[i][:end_location]]
                new_route_data_intr = get_route(start_location, end_location, trip_start_date).first[:legs]
                trip_route_attr = construct_trip_route_param(et, route_order, new_route_data_intr, route_data[i][:distance][:value], start_location, end_location, true, et.employee.bus_trip_route.stop_name, et.employee.bus_trip_route.stop_address)
                update_trip_route(et.trip_route, trip_route_attr) if et.trip_route.present?                 
                trip_array.push(trip_route_attr) if et.trip_route.blank?
              end
            end
            route_order = route_order + 1
            trip_array
          end
          new_trip_routes.flatten

          new_trip_routes.compact!
          create_trip_route(new_trip_routes) unless new_trip_routes.blank?
          process_last_waypoint(last_waypoint, reordered_waypoints.last.trip_route, trip_start_date) if last_waypoint.present?
          update_trip_info
        end
      end

      # Reorder list if next employee is male
      def reorder_waypoints(waypoints)
        if check_in? && is_female_within_radius(waypoints)
          waypoints.to_a.insert(0, waypoints.to_a.delete_at(1))
        elsif check_out? && is_female_within_radius(waypoints)
          waypoints.to_a.insert(waypoints.to_a.length-2, waypoints.to_a.delete_at(-1))
        else
          waypoints
        end
      end

      def update_trip_route(trip_route_obj, trip_route_param)
        trip_route_obj.update(trip_route_param)
      end

      def create_trip_route(trip_route_param)
        trip_routes.create!(trip_route_param)
      end

      # Female employee in x kilometer radius with male employee, then re-order the waypoints
      # and Pickup the male first and drop the male last.
      def is_female_within_radius(waypoints)
        points = check_in? ? waypoints.first(2) : waypoints.last(2)
        return false if is_male_present?(points)
        start_location, end_location = points.first.home_address, points.last.home_address
        route = get_route(start_location, end_location).first[:legs]
        diatance = route.first[:distance][:value] / 1000.0
        diatance.round <= PICKUP_OR_DROP_SWAP_RADIUS
      end

      def is_male_present?(waypoints)
        waypoints.map { |et| et.employee.gender }.include? "male"
      end

      # Set guard prosition on the Top or bottom based on the trip trip
      def move_guard_position(waypoints, guard)
        gurad_et_position = waypoints.map(&:id).index(guard.id)
        check_in? ? waypoints.to_a.insert(0, waypoints.to_a.delete_at(gurad_et_position)) : waypoints.to_a.insert(-1, waypoints.to_a.delete_at(gurad_et_position))
      end

      def update_trip_info
        return if employee_trips.empty?
        uniq_stops = trip_routes.to_a.uniq {|e| e.scheduled_route_order}
        duration = uniq_stops.map(&:scheduled_duration).sum + self.wait_time_trip * uniq_stops.size
        distance = uniq_stops.map(&:scheduled_distance).sum

        trip_start_date = employee_trips.minimum(:date)
        trip_start_date = check_in? ? trip_start_date - (duration + self.time_to_arrive).minutes : trip_start_date + self.time_to_arrive.minutes
        update_attributes!(planned_approximate_duration: duration, planned_approximate_distance: distance, planned_date: trip_start_date, scheduled_date: trip_start_date, scheduled_approximate_duration: duration, scheduled_approximate_distance: distance)
      end

      # @TODO - refactoring: handle google maps failures
      def get_route(start_location, end_location, trip_start_date="", waypoints=[])
        optimize_waypoints = !waypoints.empty?
        if is_manual
          optimize_waypoints = false
        end
        trip_start_date = Time.now.in_time_zone(Time.zone).to_i if trip_start_date.blank?
        GoogleService.new.directions(
          start_location,
          end_location,
          mode: 'driving',
          waypoints: waypoints,
          optimize_waypoints: optimize_waypoints,
          departure_time: trip_start_date
        )
      end

      # @TODO - refactoring: handle google maps failures
      def get_bus_route(start_location, end_location, trip_start_date="", waypoints=[])
        trip_start_date = Time.now.in_time_zone(Time.zone).to_i if trip_start_date.blank?
        GoogleService.new.directions(
          start_location,
          end_location,
          mode: 'driving',
          waypoints: waypoints,
          optimize_waypoints: false,
          departure_time: trip_start_date
        )
      end      

      def construct_trip_route_param(employee_trip, route_order, route_info, distance_value, start_location, end_location, bus_rider = false, bus_stop_name = "", bus_stop_address = "")
        {
          employee_trip: employee_trip,
          planned_route_order: route_order,
          planned_duration: (route_info[0][:duration_in_traffic][:value].to_f / 60).ceil,
          planned_distance: distance_value,
          planned_start_location: start_location,
          planned_end_location: end_location,
          scheduled_route_order: route_order,
          scheduled_duration: (route_info[0][:duration_in_traffic][:value].to_f / 60).ceil,
          scheduled_distance: distance_value,
          scheduled_start_location: start_location,
          scheduled_end_location: end_location,
          bus_rider: bus_rider,
          bus_stop_name: bus_stop_name,
          bus_stop_address: bus_stop_address
        }
      end

      def process_last_waypoint(last_waypoint, last_trip_route, trip_start_date)
        origin = last_trip_route.scheduled_end_location
        destination = last_trip_route.scheduled_end_location
        route = get_route(origin.values, destination, trip_start_date).first[:legs]
        trip_route_param = construct_trip_route_param(last_waypoint, last_trip_route.scheduled_route_order+1, route, route.first[:distance][:value], origin, route.first[:end_location])
        # update_trip_route(last_waypoint.trip_route, trip_route_param) if last_waypoint.trip_route.present?
        last_waypoint.trip_route.present? ? update_trip_route(last_waypoint.trip_route, trip_route_param) : create_trip_route([trip_route_param])
      end
    end
  end
end
