require 'services/google_service'

module API::V1
  class DriversController < BaseController
    before_filter :authenticate_user!, :unless => :is_from_sms?
    before_action :set_driver

    api :GET, '/drivers/:id'
    description 'Returns driver profile data'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'Not found'
    example'
    {
      "id": 42,
      "username": "driver",
      "email": "driver@n3wnormal.com",
      "f_name": "Driver",
      "m_name": null,
      "l_name": "Test",
      "phone": "5554433",
      "profile_picture": null,
      "operating_organization": {
        "name": "oo_name",
        "phone": "oo_phone"
      },
      "administrative_organization": {
        "name": "ao_name",
        "phone": "ao_phone"
      }
    }'
    def show
      if !is_from_sms?
        authorize! :read, @driver
      end
    end

    api :GET, '/drivers/:id/upcoming_trip'
    description "Returns driver's most recent upcoming trip"
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'No upcoming trips found'
    example'
    {
      "driver_status": "on_duty",
      "id": 4,
      "status": "assigned",
      "trip_type": "check_in",
      "passengers": 2,
      "approximate_duration": 21,
      "approximate_distance": 6456,
      "date": 1479193200,
      "next_pickup_date": 1479193200,
      "vehicle": {
        "id": 1,
        "plate_number": "CA12345AA",
        "make": "Tesla",
        "model": "Model X",
        "colour": "black",
        "seats": 4,
        "make_year": 2012,
        "photo": "http://example.com/photo.png"
      }
    }'
    def upcoming_trip
      if !is_from_sms?
        authorize! :read, @driver
      end

      @trip = @driver.closest_unstarted_trip
      @vehicle = @driver.vehicle
      @driver_request = DriverRequest.where(:driver => @driver).where('start_date < ? AND end_date > ?', Time.now, Time.now).where(:request_state => :approved).first
      if @driver_request.blank?
        @driver_request = DriverRequest.where(:driver => @driver).where('start_date > ?', Time.now).where(:request_state => :pending).first
      end
    end

    api :GET, '/drivers/:id/trip_history'
    description "Returns driver's completed trip list"
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'No upcoming trips found'
    example'[
      {
        "id": 1,
        "status": "completed",
        "trip_type": "check_in",
        "real_duration": 3,
        "approximate_distance": 7928,
        "start_date": 1483614998,
        "date": 1483939200,
        "site_name": "PwC - DLF Cyber City"
      },
      {
        "id": 2,
        "status": "completed",
        "trip_type": "check_in",
        "real_duration": 7,
        "approximate_distance": 7928,
        "start_date": 1483615002,
        "date": 1484025600,
        "site_name": "PwC - DLF Cyber City"
      }
    ]'
    def trip_history
      authorize! :read, @driver

      @trips = @driver.trips.completed.order(start_date: :desc).limit(20)
    end

    api :POST, '/drivers/:id/on_duty'
    description 'Set driver as active and attach a car to him'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'Driver not found'
    error code: 422, desc: 'Unprocessable entity'
    example'
    {
      "success": true,
      "vehicle": {
        "id": 2,
        "plate_number": "CA1002AA",
        "make": "Tesla",
        "model": "Model S",
        "colour": "Black",
        "seats": 5,
        "make_year": 2015,
        "photo": "http://example.com/photo.png"
      }
    }'
    def on_duty
      if !is_from_sms?
        authorize! :edit, @driver
      end

      #@vehicle = Vehicle.find_by_plate_number(params[:plate_number])
      @vehicle = Vehicle.where("replace(lower(plate_number), ' ', '') = replace(?, ' ', '')", params[:plate_number].downcase).first

      if @vehicle.nil?
        render 'api/v1/vehicles/_not_found', status: 404
      else
        unless @driver.attach_vehicle(@vehicle) && @driver.go_on_duty!
          render '_errors', status: 422
        end
      end
    end

    def change_vehicle
      if !is_from_sms?
        authorize! :edit, @driver
      end

      if @driver.has_active_trip
        # Do not allow to change vehicle in case of any active trip
        @error = "Driver has a active trip"
        render '_active_trip', status: 424
        return
      end

      #@vehicle = Vehicle.where('lower(plate_number) = ?', params[:plate_number].downcase).first
      @vehicle = Vehicle.where("replace(lower(plate_number), ' ', '') = replace(?, ' ', '')", params[:plate_number].downcase).first

      if @vehicle.nil?
        render 'api/v1/vehicles/_not_found', status: 404
      else
        unless @driver.attach_vehicle(@vehicle)
          render '_errors', status: 422
        end
      end
    end

    api :DELETE, '/drivers/:id/off_duty'
    description 'Set driver as unavailable, unassign a car'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'Driver not found'
    error code: 422, desc: 'Unprocessable entity'
    example'
    {
      "success": true
    }'
    def off_duty
      if !is_from_sms?
        authorize! :edit, @driver
      end

      if @driver.has_active_trip
        @error = "Driver has a active trip"
        render '_active_trip', status: 424
      else
        unless @driver.go_off_duty!
          render '_errors', status: 422
        end
      end

    end

    def report_to_duty
      if !is_from_sms?
        authorize! :edit, @driver
      end

      @driver_request = DriverRequest.where(:driver => @driver).where('start_date < ? AND end_date > ?', Time.now, Time.now).where(:request_state => [:approved]).first
      if @driver_request.present?
        @driver.call_operator
        @driver_request.cancel!
        @driver_request.reload
        render 'api/v1/driver_requests/create', status: 200
      else
        render '_errors', status: 422
      end
    end

    def vehicle_ok_now
      if !is_from_sms?
        authorize! :edit, @driver
      end

      #Fetch the request
      @driver_request = DriverRequest.where(:vehicle => @driver.vehicle).where(:driver => @driver).where(:request_state => [:approved]).first
      if @driver_request.present?
        #Connect a call between operator and driver
        @driver.call_operator
        @driver_request.cancel!
        @driver_request.reload
        render 'api/v1/driver_requests/create', status: 200
      else
        render '_errors', status: 422
      end
    end    

    def vehicle_info
      @vehicle = Vehicle.where('plate_number LIKE ?', "%#{params[:vehicle_id]}").first
      if !@vehicle.present?
        render '_errors', status:422
      end
    end

    api :GET, '/drivers/:id/last_trip_request'
    description 'Get latest available trip request. Will be deprecated when push notifications would be done'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'Driver not found'
    example'
    {
      "id": 2,
      "status": "assign_requested",
      "trip_type": "check_in",
      "date": 1479106800
    }'
    def last_trip_request
      if !is_from_sms?
        authorize! :read, @driver
      end

      @trip = @driver.trips.where(:status => ['assign_requested', 'assign_request_expired']).order(assign_request_expired_date: :asc).last
    end

    api :POST, '/drivers/:id/update_current_location'
    description 'Update the current location for on duty driver and send a push to all employees on that trip for real time update'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'Driver not found'
    example'
    {
      "success": true,
      "updatedETA": "updated ETA"
    }'
    def update_current_location
      authorize! :read, @driver      

      if params[:lat].blank? || params[:lng].blank?
        #Do not process this API in case any of lat or longitude in blank
        return
      end

      # Get the current trip of this driver
      latlng = [params[:lat], params[:lng]]

      # Save the current location of the driver in trip location
      @trip = Trip.where(id: params[:trip_id]).first

      if @trip.blank?
        return
      end 
     
      # Do not save the location in case the trip has been completed
      if !@trip.active?
        return
      end

      if params[:flag].blank? || params[:flag] == "false"
        # Check if we got any trip location in a period of last 2 mins
        @trip_locations = @trip.trip_location.where('time > ?', Time.now - 2.minutes).first
        if @trip_locations.present?
          # Do not process in case we saved a location in a time span on less than 2 minutes
          return
        end
      end

      @trip.set_trip_location({:lat => params[:lat].to_f, :lng => params[:lng].to_f}, 0, "0")

      # Get all the trip routes corresponding to this trip
      @trip_routes = TripRoute.where(trip_id: params[:trip_id]).where(:status => ['on_board', 'not_started', 'driver_arrived']).order(scheduled_route_order: :asc)

      # Keep on adding duration for each employee
      duration = []
      i = 0

      @trip_routes.each do |trip_route|
        all_employees_picked = false
        if trip_route.check_trip_type == 'check_in'
          if trip_route.check_if_all_employees_picked_up == true
            all_employees_picked = true
            start_location = latlng
            end_location = [@trip_routes[@trip_routes.size - 1].scheduled_end_location[:lat], @trip_routes[@trip_routes.size - 1].scheduled_end_location[:lng]]
          elsif trip_route.check_trip_status == 'not_started'
            if duration.empty?
              # Find the duration taken to pick up the first employee
              start_location = latlng
              end_location = [trip_route.scheduled_start_location[:lat], trip_route.scheduled_start_location[:lng]]
              route = GoogleService.new.directions(
                  start_location,
                  end_location,
                  avoid: 'tolls',
                  mode: 'driving',
                  departure_time: Time.now.in_time_zone(Time.zone)
              )
              route_data = route.first[:legs]
              duration.push((route_data[0][:duration_in_traffic][:value].to_f / 60).ceil)
            end
            start_location = [trip_route.scheduled_start_location[:lat], trip_route.scheduled_start_location[:lng]]
            end_location = [trip_route.scheduled_end_location[:lat], trip_route.scheduled_end_location[:lng]]
          end
        elsif trip_route.check_trip_type == 'check_out'
          if trip_route.check_trip_status == 'not_started' || trip_route.check_trip_status == 'driver_arrived'
            all_employees_picked = true
            start_location = latlng
            end_location = [@trip_routes[0].scheduled_start_location[:lat], @trip_routes[0].scheduled_start_location[:lng]]
          elsif trip_route.check_trip_status == 'on_board'
            if duration.empty?
              # Find the duration taken to pick up the first employee              
              start_location = latlng
              end_location = [trip_route.scheduled_end_location[:lat], trip_route.scheduled_end_location[:lng]]
            else
              start_location = [trip_route.scheduled_start_location[:lat], trip_route.scheduled_start_location[:lng]]
              end_location = [trip_route.scheduled_end_location[:lat], trip_route.scheduled_end_location[:lng]]
            end            
          end
        end

        if all_employees_picked == true
          duration = []
          route = GoogleService.new.directions(
              start_location,
              end_location,
              mode: 'driving',
              avoid: 'tolls',
              departure_time: Time.now.in_time_zone(Time.zone)
          )
          route_data = route.first[:legs]
          # duration = (route_data[0][:duration_in_traffic][:value].to_f / 60).ceil
          duration.push((route_data[0][:duration_in_traffic][:value].to_f / 60).ceil)
          trip_route.send_location_update(duration, all_employees_picked, @trip_routes)
          break
        end
        if i == @trip_routes.size - 1
          route = GoogleService.new.directions(
              start_location,
              end_location,
              mode: 'driving',
              avoid: 'tolls',
              departure_time: Time.now.in_time_zone(Time.zone)
          )
          route_data = route.first[:legs]
          # duration = (route_data[0][:duration_in_traffic][:value].to_f / 60).ceil
          duration.push((route_data[0][:duration_in_traffic][:value].to_f / 60).ceil)
          trip_route.send_location_update(duration, all_employees_picked, @trip_routes)
          break
        end

        i = i + 1
        if start_location != nil && end_location != nil
          # Find the route for the next employee drop location
          route = GoogleService.new.directions(
              start_location,
              end_location,
              mode: 'driving',
              avoid: 'tolls',
              departure_time: Time.now.in_time_zone(Time.zone)
          )
          route_data = route.first[:legs]
          # duration = (route_data[0][:duration_in_traffic][:value].to_f / 60).ceil
          duration.push((route_data[0][:duration_in_traffic][:value].to_f / 60).ceil)
        end
      end
    end
    
    def heart_beat
      if params[:lat].blank? || params[:lng].blank?
        #Do not process this API in case any of lat or longitude in blank
        current_user.update!(:last_active_time => Time.now)
        return
      end
      current_user.update!(:current_location => {:lat => params[:lat].to_f, :lng => params[:lng].to_f}, :last_active_time => Time.now)
      # update driver pickup times for assigned, unassigned, expired and pending trips
      # @driver.update_pickup_times      
    end

    def driver_request
      #Get active trip of driver
      # @trips = Trip.where(:driver => @driver).where(:status => ['active']).first
      # puts "Harman Sohanpal"
      # puts @trips

      # if @trips.present? && params[:exception_type] == 'On Leave'
      #   # Do not allow on leave in case of any active trip
      #   render '_errors', status: 422
      #   return
      # end

      # if @trips.present? && params[:exception_type] == 'Car Broke Down'
      #   # Notify employees in case of any active trip
      #   @trips.notify_employee_driver_trip_exception
      # end
      
      # @driver.driver_trip_exception(params[:exception_type])
      if !is_from_sms?
        authorize! :edit, @driver
      end

      @driver_request = @driver.driver_requests.new(
          reason: params[:reason],
          request_type: params[:request_type],
          driver: @driver,
          request_date: Time.now
      )

      @driver_request.start_date = Time.at(params[:start_date].to_i / 1000) if params[:start_date] != 0
      @driver_request.end_date = Time.at(params[:end_date].to_i / 1000) if params[:end_date] != 0

      if params[:request_type] == 'car_broke_down'
        @driver_request.vehicle = @driver.vehicle
        #Connect a call between driver and the operator
        @driver.call_operator
      elsif params[:request_type] == 'leave'
        @trips = Trip.where(:driver => @driver).where(:status => ['active', 'assigned', 'assign_requested', 'assign_request_expired']).first
        if @trips.present?
          # Do not allow on leave in case of any active trip
          render '_errors', status: 422
          return
        end        
      end
      #@driver_request.start_date = Time.now + 1.minutes
      #@driver_request.end_date = Time.now + 3.minutes

      if @driver_request.save
        render 'api/v1/driver_requests/create', status: 200
      else
        render 'api/v1/driver_requests/_error', status: 422
      end      
    end

    def call_operator
      @driver.call_operator
    end

    protected

    def set_driver
      @driver = Driver.find_by_user_id(params[:id])
    end

    def is_from_sms?
      params[:is_from_sms] == "true"
    end
  end
end
