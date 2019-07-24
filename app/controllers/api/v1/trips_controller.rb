require 'services/trip_validation_service'

module API::V1
  class TripsController < BaseController
    before_filter :authenticate_user!, :unless => :is_from_sms?
    before_action :set_trip
    before_action :set_trip_routes, only: [ :driver_arrived, :on_board, :completed, :missed, :resolve_exception, :not_on_board ]

    api :GET, '/trips/:id'
    description 'Return trip by id'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip not found'
    example'{
      "id": 4,
      "status": "assigned",
      "trip_type": "check_out",
      "passengers": 2,
      "approximate_duration": 95,
      "approximate_distance": 77349,
      "date": 1480342200,
      "site": {
        "id": 1,
        "name": "Site_test",
        "location": {
          "latitude": "49.443687",
          "longitude": "32.051969"
        }
      },
      "trip_routes": [
        {
          "id": 7,
          "route_order": 0,
          "status": "not_started",
          "eta": 1480342800,
          "employee": {
            "id": 4,
            "username": "employee",
            "f_name": "Employee",
            "m_name": null,
            "l_name": "Test",
            "email": "employee@n3wnormal.com",
            "phone": "6665544",
            "home_address": "22 Heroiv Stalinhradu str, Cherkasy, Ukraine",
              "home_address_location": {
                "latitude": "49.435964",
                "longitude": "32.093944"
              }
          }
        },
        {
          "id": 8,
          "route_order": 1,
          "status": "not_started",
          "eta": 1480347720,
          "employee": {
            "id": 5,
            "username": "employee2",
            "f_name": "Employee2",
            "m_name": null,
            "l_name": "Test",
            "email": "employee2@n3wnormal.com",
            "phone": "66655442",
            "home_address": "Koneva 5, Cherkasy",
            "home_address_location": {
              "latitude": "49.416254",
              "longitude": "31.275124"
            }
          }
        }
      ]
    }'
    def show
      if !is_from_sms?
        authorize! :read, @trip
      end
      @config_values = TripValidationService.driver_config_params(@trip)
    end

    api :GET, '/trips/:id/start'
    description 'Driver started the trip'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip not found'
    example'{
      "success": true
    }'
    def start
      begin
        # Update the trip route by factoring in the driver current location
        unless params[:lat].blank? || params[:lng].blank?
          @trip.update_route(params[:lat], params[:lng])
        end

        if @trip.start_trip!
          unless params[:request_date].blank?
            @trip.save_actual_start_trip_date(params[:request_date])
          end
          unless params[:lat].blank? || params[:lng].blank?
            @trip.set_trip_location({:lat => params[:lat].to_f, :lng => params[:lng].to_f}, 0, "0")
            #if ENV["CALCULATE_ETA"] == "true"
              #CalculateEtaWorker.perform_async(@trip.id)
            #end
          end
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'show', status: 200
        else
          @trip.reload
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'show', status: 422
        end
      rescue
        @trip.update(:cancel_status => "Backend Issue")
        @trip.cancel_complete_trip
        render '_errors', status: 451
      end

    end

    api :GET, '/trips/:id/decline_trip_request'
    description 'Driver declines incoming trip request'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip not found'
    example'{
      "success": true
    }'
    def decline_trip_request
      unless @trip.driver && @trip.driver.user == current_user
        render '_trip_assign_request_expired', status: 422
        return
      end

      if !is_from_sms?
        authorize! :manage_trip_request, @trip
      end

      if @trip.assign_request_declined!
        @trip.unassign_driver_info
        @trip.unassign_driver!
        render 'decline_trip_request', status: 200
      else
        render '_errors', status: 422
      end

    end

    api :GET, '/trips/:id/accept_trip_request'
    description 'Driver accept incoming trip request'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip not found'
    example'{
      "success": true,
      "trip": {
        "id": 2,
        "status": "assigned",
        "trip_type": "check_in",
        "date": 1479106800
      }
    }'
    def accept_trip_request
      begin
        if !is_from_sms?
          unless @trip.driver && @trip.driver.user == current_user
            render '_trip_assign_request_expired', status: 422
            return
          end
          authorize! :manage_trip_request, @trip
        end

        if @trip.assign_request_accepted!
          unless params[:request_date].blank?
            @trip.save_actual_trip_accept_date(params[:request_date])
          end

          render 'accept_trip_request', status: 200
        else
          @trip.reload
          render 'accept_trip_request', status: 422
        end
      rescue
        @trip.update(:cancel_status => "Backend Issue")
        @trip.cancel_complete_trip
        render '_errors', status: 451
      end      
    end


    api :POST, '/trips/:id/trip_routes/driver_arrived'
    description 'Driver marked that he\'s arrived'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip not found'
    example '
    {
      "success": true
    }'
    def driver_arrived
      begin
        if !is_from_sms?
          authorize! :driver_arrived, @trip
        end

        errors = false
        #Geo fence check
        @trip_routes.each do |trip_route|
          if @trip.trip_type == 'check_in'
            unless params[:lat].blank? || params[:lng].blank?
              trip_route.check_driver_arrived_geofence(params[:lat], params[:lng])
            end        
          else
            unless params[:lat].blank? || params[:lng].blank?
              #Send notification only once
              trip_route.check_driver_arrived_geofence(params[:lat], params[:lng])
              break
            end          
          end
        end

        @trip_routes.each do |trip_route|
          unless params[:lat].blank? || params[:lng].blank?
            trip_route.update(driver_arrived_location: {:lat => params[:lat].to_f, :lng => params[:lng].to_f})
          end

          unless params[:request_date].blank?
            trip_route.set_actual_driver_arrived_date(params[:request_date])
          end

          if !trip_route.driver_arrived?
            errors = true unless trip_route.driver_arrived!
          end
        end

        if errors
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'show', status: 422
        else
          if @trip.active?
            #if ENV["CALCULATE_ETA"] == "true"          
              #CalculateEtaWorker.perform_async(@trip.id)
            #end
          end        
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'show', status: 200
        end
      rescue
        @trip.update(:cancel_status => "Backend Issue")
        @trip.cancel_complete_trip
        render '_errors', status: 451
      end      
    end

    api :POST, '/trips/:id/trip_routes/on_board'
    description 'Driver marked that employee was boarded'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip not found'
    example '
    {
      "success": true
    }'
    def on_board
      begin
        if !is_from_sms?
          authorize! :on_board, @trip
        end

        errors = false

        #Geo fence check
        @trip_routes.each do |trip_route|
          if @trip.trip_type == 'check_in'
            unless params[:lat].blank? || params[:lng].blank?
              trip_route.check_on_board_geofence(params[:lat], params[:lng])
            end
          else
            unless params[:lat].blank? || params[:lng].blank?
              #Send notification only once
              trip_route.check_on_board_geofence(params[:lat], params[:lng])
            end          
          end
        end

        @trip_routes.each do |trip_route|
          unless params[:lat].blank? || params[:lng].blank?
            trip_route.update(check_in_location: {:lat => params[:lat].to_f, :lng => params[:lng].to_f})
          end

          unless params[:request_date].blank?
            trip_route.set_actual_on_board_date(params[:request_date])
          end

          if !trip_route.on_board?  
            errors = true unless trip_route.boarded!
          end
        end

        if errors
          @trip.reload
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'show', status: 422
        else
          if @trip.active?
            #if ENV["CALCULATE_ETA"] == "true"
              #CalculateEtaWorker.perform_async(@trip.id)
            #end
          end        
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'show', status: 200
        end
      rescue
        @trip.update(:cancel_status => "Backend Issue")
        @trip.cancel_complete_trip
        render '_errors', status: 451
      end      
    end

    api :POST, '/trips/:id/trip_routes/completed'
    description 'Driver marked that employee has been delivered'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip not found'
    example '
    {
      "success": true
    }'
    def completed
      begin
        if !is_from_sms?
          authorize! :on_board, @trip
        end

        errors = false

        #Geo fence check
        @trip_routes.each do |trip_route|
          if @trip.trip_type == 'check_in'
            unless params[:lat].blank? || params[:lng].blank?
              trip_route.check_completed_geofence(params[:lat], params[:lng])
              break
            end
          else
            unless params[:lat].blank? || params[:lng].blank?
              #Send notification only once
              trip_route.check_completed_geofence(params[:lat], params[:lng])
            end          
          end
        end

        @trip_routes.each do |trip_route|
          unless params[:lat].blank? || params[:lng].blank?
            trip_route.update(drop_off_location: {:lat => params[:lat].to_f, :lng => params[:lng].to_f})
          end

          unless params[:request_date].blank?
            trip_route.set_actual_completed_date(params[:request_date])
          end

          if !trip_route.completed?
            if trip_route.not_on_board?
              errors = true unless trip_route.not_on_board_completed!
            else
              errors = true unless trip_route.completed!
            end            
          end
        end

        if errors
          @trip.reload
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'show', status: 422
        else
          if @trip.active?
            #if ENV["CALCULATE_ETA"] == "true"
              #CalculateEtaWorker.perform_async(@trip.id)
            #end
          end        
          @trip.reload # Reload trip attributes after it has been updated
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'show', status: 200
        end
      rescue
        @trip.update(:cancel_status => "Backend Issue")
        @trip.cancel_complete_trip
        render '_errors', status: 451
      end      
    end

    api :POST, '/trips/:id/trip_routes/not_on_board'
    description 'Driver marked that he has moved to next step'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip not found'
    example '
    {
      "success": true
    }'
    def not_on_board
      begin
        if !is_from_sms?
          authorize! :not_on_board, @trip
        end

        errors = false

        @trip_routes.each do |trip_route|
          unless params[:lat].blank? || params[:lng].blank?
            trip_route.update(move_to_next_step_location: {:lat => params[:lat].to_f, :lng => params[:lng].to_f})
          end

          unless params[:request_date].blank?
            trip_route.set_move_to_next_step_date(params[:request_date])
          end

          if trip_route.driver_arrived?
            errors = true unless trip_route.not_on_board!
          end
        end

        if errors
          @trip.reload
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'show', status: 422
        else      
          @trip.reload # Reload trip attributes after it has been updated
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'show', status: 200
        end
      rescue
        @trip.update(:cancel_status => "Backend Issue")
        @trip.cancel_complete_trip
        render '_errors', status: 451
      end      
    end

    def change_status_request_assigned
      @trip.assign_driver_accept_restarted!
      @trip.reload      
    end

    def resolve_exception
      errors = []
      @trip_route_exception = TripRouteException.where(:trip_route => @trip_routes).where(:exception_type => 'employee_no_show').where(:status => 'open')
      @trip_route_exception.each do |trip_route_exception|
        if !trip_route_exception.resolved!
          # return full trip to driver to maintain actual app status
          errors.push(trip_route_exception.errors.full_messages)
        end
      end

      @notification = Notification.where(:trip => @trip, :message => 'employee_no_show', :employee => @trip_routes.first.employee_trip.employee, :resolved_status => false)
      @notification.each do |notification|
        notification.update!(resolved_status: true)
      end

      if errors.blank?
        if current_user.driver?
          @trip.reload
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'api/v1/trips/show', status: 200
        else
          render 'api/v1/base/_success', status: 200
        end
      else
        render 'api/v1/base/_errors', status: 422
      end
    end

    protected
    def set_trip
      @trip = Trip.find(params[:id])
    end

    def set_trip_routes
      @trip_routes = @trip.trip_routes.where(id: params[:trip_routes])
    end

    def is_from_sms?
      if params[:is_from_sms] == "true"
        current_user = User.find(params[:uid])
      end
      params[:is_from_sms] == "true"
    end
  end
end
