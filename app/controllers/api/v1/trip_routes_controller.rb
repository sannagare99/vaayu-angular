require 'services/trip_validation_service'

module API::V1
  class TripRoutesController < BaseController
    before_action :set_trip_route
    before_filter :authenticate_user!, :unless => :is_from_sms?

    api :GET, '/trips/:id/trip_routes/:trip_route_id/employee_no_show'
    description 'Driver marked employee did not come'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip route not found'
    example '
    {
      "success": true,
      "id": 1,
      "exception_type": "employee_no_show",
      "status": "open",
      "date": 1482830372
    }'
    # @TODO: test
    def employee_no_show
      # begin
        if !is_from_sms?
          authorize! :submit_employee_no_show, @trip_route
        end

        no_show_approval = false
        no_show_approval_required = Configurator.where(:request_type => 'no_show_approval_required').first

        if no_show_approval_required.present?
          no_show_approval = (no_show_approval_required.value == "1")
        end

        if no_show_approval
          @trip_route_exception = @trip_route.trip_route_exceptions.new( exception_type: :employee_no_show, date: Time.now )

          if @trip_route_exception.save
            @trip = @trip_route.trip
            #Connect a call between driver and operator
            @trip_route.call_operator

            #Check no show geofence
            unless params[:lat].blank? || params[:lng].blank?
              # @trip_route.check_no_show_geofence(params[:lat], params[:lng])
              @trip_route.update(missed_location: {:lat => params[:lat] .to_f, :lng => params[:lng].to_f})
            end

            reporter = "Driver: #{@trip.driver.full_name}"
            @notification = Notification.where(:trip => @trip, :driver => @trip.driver, :employee => @trip_route.employee, :message => 'employee_no_show', :resolved_status => false).first

            if @notification.blank?
              Notification.create!(:trip => @trip, :driver => @trip.driver, :employee => @trip_route.employee, :message => 'employee_no_show', :resolved_status => false,:new_notification => true, :reporter => reporter).send_notifications
            end
            @config_values = TripValidationService.driver_config_params(@trip)
            render 'api/v1/trips/show', status: 200
          else
            @errors = @trip_route_exception.errors.full_messages
            render 'api/v1/base/_errors', status: 422
          end
        else
          @trip = @trip_route.trip
          unless params[:request_date].blank?
            @trip_route.set_actual_missed_date(params[:request_date])
          end

          #Check no show geofence
          unless params[:lat].blank? || params[:lng].blank?
            # @trip_route.check_no_show_geofence(params[:lat], params[:lng])
            @trip_route.update(missed_location: {:lat => params[:lat] .to_f, :lng => params[:lng].to_f})
          end

          errors = false

          reporter = "Driver: #{@trip.driver.full_name}"

          @notification = Notification.where(:trip => @trip, :driver => @trip.driver, :employee => @trip_route.employee, :message => 'employee_no_show').first

          if @notification.blank?
            Notification.create!(:trip => @trip, :driver => @trip.driver, :employee => @trip_route.employee, :message => 'employee_no_show', :resolved_status => true,:new_notification => true, :reporter => reporter).send_notifications
          end

          @prev_no_show_approved_notification = Notification.where(:trip => @trip, :driver => @trip.driver, :employee => @trip_route.employee, :message => 'employee_no_show_approved', :resolved_status => false).first

          if @prev_no_show_approved_notification.blank?
            @no_show_approved_notification = Notification.create!(:trip => @trip, :driver => @trip.driver, :employee => @trip_route.employee, :message => 'employee_no_show_approved', :resolved_status => false, :new_notification => true, :reporter => "Moove System")
            @no_show_approved_notification.send_notifications
            ResolveNotification.perform_at(Time.now + 10.minutes, @no_show_approved_notification.id)
          end

          if !@trip_route.missed?
            errors = true unless @trip_route.missed!
          end

          if errors
            @trip = @trip_route.trip
            @trip.reload
            @config_values = TripValidationService.driver_config_params(@trip)            
            render 'api/v1/trips/show', status: 422            
          else
            # @notification = Notification.create!(:trip => @trip, :driver => @trip.driver, :employee => @trip_route.employee, :message => :employee_no_show, :receiver => :operator, :resolved_status => true, :new_notification => false)
            # @notification.send_notifications

            @trip.resequence_active_trip            
            @trip.reload
            @config_values = TripValidationService.driver_config_params(@trip)
            render 'api/v1/trips/show', status: 200
          end

          # @trip_route_exception = @trip_route.trip_route_exceptions.new( exception_type: :employee_no_show, date: Time.now)

          # if @trip_route_exception.save
          #   @trip = @trip_route.trip
          #   #Connect a call between driver and operator
          #   # @trip_route.call_operator

          #   unless params[:request_date].blank?
          #     @trip_route.set_actual_missed_date(params[:request_date])
          #   end

          #   #Check no show geofence
          #   unless params[:lat].blank? || params[:lng].blank?
          #     @trip_route.check_no_show_geofence(params[:lat], params[:lng])
          #     @trip_route.update(missed_location: {:lat => params[:lat] .to_f, :lng => params[:lng].to_f})
          #   end

          #   @notification = Notification.create!(:trip => @trip, :driver => @trip.driver, :employee => @trip_route.employee, :message => @trip_route_exception.exception_type, :receiver => :operator, :resolved_status => true, :new_notification => false)
          #   @notification.send_notifications

          #   if @trip_route_exception.resolved_by_operator!
          #     render 'api/v1/trips/show', status: 200
          #   else
          #     render 'api/v1/base/_errors', status: 422  
          #   end

            
          # else
          #   @errors = @trip_route_exception.errors.full_messages
          #   render 'api/v1/base/_errors', status: 422
          # end        
        end
      # rescue
      #   @trip = @trip_route.trip
      #   @trip.update(:cancel_status => "Backend Issue")
      #   @trip.cancel_complete_trip
      #   render 'api/v1/base/_errors', status: 451
      # end        
    end

    api :POST, '/trip_routes/:trip_route_id/initiate_call'
    description 'Call a driver from employee and vice versa and panic button calling to the operator'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip not found'
    example '
    {
      "success": true
    }'
    def initiate_call
      #params call_type
      #0 - Employee to Driver
      #1 - Driver to employee
      @trip_route.initiate_call(params[:call_type])
    end

    protected
    def set_trip_route
      @trip_route = TripRoute.find(params[:id])
    end

    def is_from_sms?
      params[:is_from_sms] == "true"
    end
  end
end
