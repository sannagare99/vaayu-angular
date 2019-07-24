class TripValidationService
  MAX_DISTANCE_AWAY_IN_KM = 100.0
  RAD_PER_DEG             = 0.017453293

  Rkm     = 6371           # radius in kilometers, some algorithms use 6367
  Rmeters = Rkm * 1000     # radius in meters

	def self.is_female_exception(employee_trip_ids, trip_type)
    if trip_type == "check_in"
      #Get First employee in the route for check in trip
      @employee_trip = EmployeeTrip.find(employee_trip_ids[0])
    else
      #Get Last employee in the route for check out trip
      @employee_trip = EmployeeTrip.find(employee_trip_ids[employee_trip_ids.length - 1])
    end

    return false if @employee_trip.employee.gender == 'male' || @employee_trip.bus_rider?

    trip_shift_time = @employee_trip.date.in_time_zone("Kolkata") 

    female_exception = true
    female_exception_required = Configurator.where('request_type' => 'female_exception_required').first

    if female_exception_required.present?
      female_exception = (female_exception_required.value == '1')
    end

    if female_exception
      female_exception = false
      check_in_time = "06:00"
      check_out_time = "20:00"

      female_exception_check_in_time = Configurator.where('request_type' => 'female_exception_check_in_time').first
      female_exception_check_out_time = Configurator.where('request_type' => 'female_exception_check_out_time').first

      if female_exception_check_in_time.present?
        check_in_time = female_exception_check_in_time.value
      end

      if female_exception_check_out_time.present?
        check_out_time = female_exception_check_out_time.value
      end

     range = Time.parse("2000-01-01T#{check_in_time}:00Z")..Time.parse("2000-01-01T#{check_out_time}:00Z")

      if !range.cover? Time.parse("2000-01-01T#{trip_shift_time.strftime('%H:%M:00')}Z")
        female_exception = true
      end
    end

    female_exception
	end

  def self.show_female_exception_error(employee_trip_ids, trip_type)
    if trip_type == "check_in"
      #Get First employee in the route for check in trip
      @employee_trip = EmployeeTrip.find(employee_trip_ids[0])
    else
      #Get Last employee in the route for check out trip
      @employee_trip = EmployeeTrip.find(employee_trip_ids[employee_trip_ids.length - 1])
    end

    return false if @employee_trip.bus_rider?

    trip_shift_time = @employee_trip.date.in_time_zone("Kolkata") 

    female_exception = true
    female_exception_required = Configurator.where('request_type' => 'female_exception_required').first

    if female_exception_required.present?
      female_exception = (female_exception_required.value == '1')
    end

    if female_exception
      female_exception = false
      check_in_time = "06:00"
      check_out_time = "20:00"

      female_exception_check_in_time = Configurator.where('request_type' => 'female_exception_check_in_time').first
      female_exception_check_out_time = Configurator.where('request_type' => 'female_exception_check_out_time').first

      if female_exception_check_in_time.present?
        check_in_time = female_exception_check_in_time.value
      end

      if female_exception_check_out_time.present?
        check_out_time = female_exception_check_out_time.value
      end

     range = Time.parse("2000-01-01T#{check_in_time}:00Z")..Time.parse("2000-01-01T#{check_out_time}:00Z")

      if !range.cover? Time.parse("2000-01-01T#{trip_shift_time.strftime('%H:%M:00')}Z")
        female_exception = true
      end
    end

    female_exception    
  end

  def self.is_resequence_required(employee_trip_ids, trip_type)
    resequence_required = {
      resequence_required: false,
      first_position: -1,
      second_position: -1
    }

    return resequence_required if employee_trip_ids.length == 1

    female_exception_resequence_required = Configurator.where('request_type' => 'female_exception_resequence_required').first

    resequence_required[:resequence_required] = true

    if female_exception_resequence_required.present?
      resequence_required[:resequence_required] = (female_exception_resequence_required.value == '1')
    end

    second_waypoint = []
    if resequence_required[:resequence_required]
      if trip_type == "check_in"
        first_waypoint = EmployeeTrip.find(employee_trip_ids[0])
        resequence_required[:first_position] = 0
        employee_trip_ids.each_with_index do |et, i|
          next if i == 0
          waypoint = EmployeeTrip.find(employee_trip_ids[i])
          if waypoint.employee.gender == 'male'
            second_waypoint = waypoint
            resequence_required[:second_position] = i
            break
          end
        end
      else
        first_waypoint = EmployeeTrip.find(employee_trip_ids[employee_trip_ids.length - 1])
        resequence_required[:first_position] = employee_trip_ids.length - 1
        employee_trip_ids.each_with_index do |et, i|
          next if i == 0
          waypoint = EmployeeTrip.find(employee_trip_ids[employee_trip_ids.length - i - 1])
          if waypoint.employee.gender == 'male'
            second_waypoint = waypoint
            resequence_required[:second_position] = employee_trip_ids.length - i - 1
            break
          end
        end
      end


      if first_waypoint.employee.gender == 'male' || second_waypoint.blank?
        resequence_required[:resequence_required] = false
        return resequence_required
      end

      aerial_distance = 1.5

      female_exception_aerial_distance = Configurator.where('request_type' => 'female_exception_aerial_distance').first

      if female_exception_aerial_distance.present?
        aerial_distance = female_exception_aerial_distance.value
      end

      if first_waypoint.employee.gender == 'female' && second_waypoint.employee.gender == 'male'
        #Get distance between first and second employee
        distance = haversine_distance(first_waypoint.employee.home_address_latitude, 
          first_waypoint.employee.home_address_longitude, 
          second_waypoint.employee.home_address_latitude, 
          second_waypoint.employee.home_address_longitude)

        # Check for distance in meters
        if (distance) < aerial_distance.to_f
          resequence_required[:resequence_required] = true
          return resequence_required
        end
      end
    end

    resequence_required[:resequence_required] = false
    return resequence_required
  end

  def self.resequence_employee_trips(employee_trip_ids, trip_type)
    is_resequence_required = is_resequence_required(employee_trip_ids, trip_type)
    reordered_employee_trip_ids = []

    resequencing_error_message = ""

    if is_resequence_required[:resequence_required]
      resequencing_error_message = "Female first/last exception managed by re-sequencing"

      employee_trip_ids.each_with_index do |et, i|
        if is_resequence_required[:first_position] == i
          reordered_employee_trip_ids.push(employee_trip_ids[is_resequence_required[:second_position]])
        elsif is_resequence_required[:second_position] == i
          reordered_employee_trip_ids.push(employee_trip_ids[is_resequence_required[:first_position]])
        else
          reordered_employee_trip_ids.push(et)
        end
      end

      #Generate Notification if trip is present
      @et = EmployeeTrip.find(employee_trip_ids[is_resequence_required[:first_position]])
      if @et.trip.present?
        #Create Notification for Resequenced Trip
        @prev_notification = Notification.where(:trip => @et.trip, :driver => @et.trip.driver, :employee => @et.employee, :message => 'female_exception_route_resequenced', :resolved_status => false).first

        if @prev_notification.blank?
          @notification = Notification.create!(:trip => @et.trip, :driver => @et.trip.driver, :employee => @et.employee, :message => 'female_exception_route_resequenced', :new_notification => true, :resolved_status => false, :reporter => 'Moove System')
          @notification.send_notifications
          ResolveNotification.perform_at(Time.now + 10.minutes, @notification.id)
        end
      end
    end

    return {
        sorted_employee_trip_ids: reordered_employee_trip_ids,
        resequencing_error_message: resequencing_error_message,
        first_position: is_resequence_required[:first_position],
        second_position: is_resequence_required[:second_position],
    }
  end

  def self.haversine_distance( lat1, lon1, lat2, lon2 )
    dlon = lon2 - lon1
    dlat = lat2 - lat1

    dlon_rad = dlon * RAD_PER_DEG
    dlat_rad = dlat * RAD_PER_DEG

    lat1_rad = lat1 * RAD_PER_DEG
    lon1_rad = lon1 * RAD_PER_DEG

    lat2_rad = lat2 * RAD_PER_DEG
    lon2_rad = lon2 * RAD_PER_DEG

    a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) *
         Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))

    distance_in_meters = Rmeters * c
    distance_in_meters
  end  	

  def self.remove_first_last_female_employee(employee_trip_ids, trip_type)
    if trip_type == "check_in"
      #Get First employee in the route for check in trip
      @employee_trip = EmployeeTrip.find(employee_trip_ids[0])
    else
      #Get Last employee in the route for check out trip
      @employee_trip = EmployeeTrip.find(employee_trip_ids[employee_trip_ids.length - 1])
    end

    if @employee_trip.employee.gender == 'female'      
      #Generate Notification to remove female employee
      @notification = Notification.where(:trip => @employee_trip.trip, :driver => @employee_trip.trip.driver, :employee => @employee_trip.employee,:employee_trip => @employee_trip, :message => 'female_exception_female_removed', :resolved_status => false).first

      if @notification.blank?
        Notification.create!(:trip => @employee_trip.trip, :driver => @employee_trip.trip.driver, :employee => @employee_trip.employee,:employee_trip => @employee_trip, :message => 'female_exception_female_removed', :new_notification => true, :resolved_status => false, :reporter => 'Moove System').send_notifications
      end

      @employee_trip.remoe_employee_trip
      return true
    end

    return false
  end

  def self.driver_config_params(trip)
    status = ['female_exception_resequence_required', 'female_exception_required', 'female_exception_check_out_time', 'female_exception_check_in_time', 'female_exception_aerial_distance', 'no_show_approval_required', 'buffer_duration_for_delayed_trip_notification', 'buffer_duration_to_allow_start_trip', 'buffer_duration_for_start_trip_notification', 'driver_narrow_geofence_distance', 'driver_wide_geofence_distance', 'driver_auto_signal_i_am_here_by_geofence', 'driver_auto_complete_trip_by_geofence', 'driver_restrict_i_am_here_by_geofence']
    @configurator = Configurator.where(:request_type => status)

    @config_values = {
      female_exception_required: true,
      female_exception_resequence_required: true,
      female_exception_check_in_time: '06:00',
      female_exception_check_out_time: '20:00',
      female_exception_aerial_distance: '1.5',
      no_show_approval_required: false,
      buffer_duration_for_delayed_trip_notification: '30', 
      buffer_duration_to_allow_start_trip: '120',
      buffer_duration_for_start_trip_notification: '30',
      driver_narrow_geofence_distance: '200',
      driver_wide_geofence_distance: '1500',
      driver_auto_signal_i_am_here_by_geofence: false,
      driver_auto_complete_trip_by_geofence: false,
      driver_restrict_i_am_here_by_geofence: false
    }

    @configurator.each do |config|
      value = (config.value == "1")
      if config.request_type == 'female_exception_check_out_time' || config.request_type == 'female_exception_check_in_time' || config.request_type == 'female_exception_aerial_distance' || config.request_type == 'buffer_duration_for_delayed_trip_notification' || config.request_type == 'buffer_duration_to_allow_start_trip' || config.request_type == 'buffer_duration_for_start_trip_notification' || config.request_type == 'driver_narrow_geofence_distance' || config.request_type == 'driver_wide_geofence_distance'
        value = config.value 
      end
      @config_values[config.request_type.to_sym] = value
    end

    @config_values.merge(service_config_params(trip))    
  end

  def self.employee_config_params(trip)
    service_config_params(trip)
  end

  def self.service_config_params(trip)    
    @config_values = {
      driver_no_show_allowed: true,
      passcode_required_driver_check_in: true,
      employee_check_in_allowed: false,
      employee_no_show_allowed: false,
      move_to_next_step_required: false
    }

    case trip.service_type
      when 'D2D'
        status = ['driver_no_show_allowed_D2D', 'passcode_required_driver_check_in_D2D', 'employee_check_in_allowed_D2D', 'employee_no_show_allowed_D2D', 'move_to_next_step_required_D2D']
      when 'BUS'
        status = ['driver_no_show_allowed_BUS', 'passcode_required_driver_check_in_BUS', 'employee_check_in_allowed_BUS', 'employee_no_show_allowed_BUS', 'move_to_next_step_required_BUS']
      when 'NODAL'
        status = ['driver_no_show_allowed_NODAL', 'passcode_required_driver_check_in_NODAL', 'employee_check_in_allowed_NODAL', 'employee_no_show_allowed_NODAL', 'move_to_next_step_required_NODAL']
    end

    @configurator = Configurator.where(:request_type => status)

    @configurator.each do |config|
      value = (config.value == "1")

      @config_values[config.request_type.rpartition('_').first.to_sym] = value
    end

    @config_values
  end

  def self.is_nodal(employee, date)
    date = date.in_time_zone("Kolkata")

    is_nodal = false
    # Check if the is nodal is checked in the configurator
    is_nodal_trip_allowed = Configurator.where('request_type' => 'is_nodal_trip_allowed').first
    if is_nodal_trip_allowed.present?
      is_nodal = is_nodal_trip_allowed.value == '1'
    end

    if is_nodal
      #Check if the nodal
      if (employee.nodal_address.blank? || 
        employee.nodal_address_latitude.blank? || 
        employee.nodal_address_longitude.blank?|| 
        employee.nodal_name.blank?)
        is_nodal = false
      end
    end

    # Check if the time for trip is within aloowed time
    if is_nodal
      check_in_time = "06:00"
      check_out_time = "20:00"

      start_time_NODAL = Configurator.where('request_type' => 'start_time_NODAL').first
      end_time_NODAL = Configurator.where('request_type' => 'end_time_NODAL').first

      if start_time_NODAL.present?
        start_time = start_time_NODAL.value
      end

      if end_time_NODAL.present?
        end_time = end_time_NODAL.value
      end

      range = Time.parse("2000-01-01T#{start_time}:00Z")..Time.parse("2000-01-01T#{end_time}:00Z")

      if !range.cover? Time.parse("2000-01-01T#{date.strftime('%H:%M:00')}Z")
        is_nodal = false
      end      
    end

    is_nodal
  end

  def self.is_nodal_allowed
    is_nodal = false
    # Check if the is nodal is checked in the configurator
    is_nodal_trip_allowed = Configurator.where('request_type' => 'is_nodal_trip_allowed').first
    if is_nodal_trip_allowed.present?
      is_nodal = is_nodal_trip_allowed.value == '1'
    end

    # Check if the time for trip is within aloowed time
    if is_nodal
      check_in_time = "06:00"
      check_out_time = "20:00"

      start_time_NODAL = Configurator.where('request_type' => 'start_time_NODAL').first
      end_time_NODAL = Configurator.where('request_type' => 'end_time_NODAL').first

      if start_time_NODAL.present?
        start_time = start_time_NODAL.value
      end

      if end_time_NODAL.present?
        end_time = end_time_NODAL.value
      end
    end

    {
      :is_nodal => is_nodal,
      :start_time => start_time,
      :end_time => end_time
    }
  end

  def self.check_if_nodal_trip(employee, date, start_time, end_time)
    is_nodal = true
    #Check if the nodal
    if (employee.nodal_address.blank? || 
      employee.nodal_address_latitude.blank? || 
      employee.nodal_address_longitude.blank?|| 
      employee.nodal_name.blank?)
      is_nodal = false
    end

    range = Time.parse("2000-01-01T#{start_time}:00Z")..Time.parse("2000-01-01T#{end_time}:00Z")

    if !range.cover? Time.parse("2000-01-01T#{date.strftime('%H:%M:00')}Z")
      is_nodal = false
    end

    is_nodal
  end

  def self.get_sorted_routes(params)
    waypoints = EmployeeTrip.where(:id => params).joins(:employee).order("employees.distance_to_site DESC")
    waypoints = waypoints.to_a.compact

    first_waypoint = waypoints.shift

    #Check for female exceptions
    ret = false

    trip_shift_time = first_waypoint.date.in_time_zone('Chennai').strftime('%H:%M')

    # Default value of female exception is always true
    female_exception = true
    show_female_exception_error = false

    sorted_employee_trips = []

    resequencing_error_message = ""

    sorted_employee_trip_ids = []

    if !waypoints.blank?
      origin = first_waypoint.site_location

      destination = waypoints.first.home_address

      route = get_route(origin, destination, Time.now.in_time_zone('Chennai'), waypoints.map{|et| et.home_address})
      reordered_waypoints = route.first[:waypoint_order].map{|i| waypoints[i]}
      reordered_waypoints.push(first_waypoint)

      route_data = route.first[:legs]

      if first_waypoint.check_in?
        reordered_waypoints = reordered_waypoints.reverse
      end

      reordered_waypoints.each do |employee_trip|
        sorted_employee_trip_ids.push(employee_trip.id)
      end

      female_exception = TripValidationService.is_female_exception(sorted_employee_trip_ids, first_waypoint.trip_type)

      show_female_exception_error = TripValidationService.show_female_exception_error(sorted_employee_trip_ids, first_waypoint.trip_type)

      if female_exception
        # Default Values
        # Check if female exception is enabled and shift time is outside valid shifts.
        ret = TripValidationService.resequence_employee_trips(sorted_employee_trip_ids, first_waypoint.trip_type)
        sorted_employee_trip_ids = ret[:sorted_employee_trip_ids] if ret[:sorted_employee_trip_ids].present?
        resequencing_error_message = ret[:resequencing_error_message]
      end

      sorted_employee_trip_ids.each do |id|
        sorted_employee_trips.push("#{EmployeeTrip::DATATABLE_PREFIX}-#{id}")
      end
    else
      sorted_employee_trip_ids.push(first_waypoint.id)
      female_exception = TripValidationService.is_female_exception(sorted_employee_trip_ids, first_waypoint.trip_type)
      sorted_employee_trips.push("#{EmployeeTrip::DATATABLE_PREFIX}-#{first_waypoint.id}")
    end

    @response = {
        :sorted_employee_trip_ids => sorted_employee_trip_ids,
        :sorted_employee_trips => sorted_employee_trips,
        :error => resequencing_error_message,
        :female_exception => female_exception,
        :show_female_exception_error => show_female_exception_error
    }
  end

  # @TODO - refactoring: handle google maps failures
  def self.get_route(start_location, end_location, trip_start_date="", waypoints=[])
    trip_start_date = Time.now.in_time_zone(Time.zone).to_i if trip_start_date.blank?
    GoogleService.new.directions(
      start_location,
      end_location,
      mode: 'driving',
      waypoints: waypoints,
      optimize_waypoints: true,
      departure_time: trip_start_date
    )
  end    
end

#########
# Ingest - check_if_female_exception(shift_time) && first employee is female - Add a cluster error saying Female is first in the trip

# Auto Clustering - 
# Create a sequence.
# check_if_female_exception(shift_time)
# check_if_resequence_required_in_trip(id1, id2)

# one female - female_exception - Add a cluster error saying Female is first in the trip
