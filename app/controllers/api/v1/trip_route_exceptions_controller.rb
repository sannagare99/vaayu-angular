require 'services/trip_validation_service'

module API::V1
  class TripRouteExceptionsController < BaseController
    before_action :set_trip_route_exception

    api :GET, '/trip_route_exceptions/:id/resolve'
    description 'Employee marked that trip exception has been resolved'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Employee cannot resolve others exception'
    error code: 404, desc: 'Trip route exception not found'
    example '
    {
      "success": true
    }'
    # @TODO test
    def resolve
      authorize! :edit, @trip_route_exception

      if @trip_route_exception.resolved!

        @notification = Notification.where(:trip => @trip_route_exception.trip, :message => @trip_route_exception.exception_type, :employee => @trip_route_exception.trip_route.employee_trip.employee, :resolved_status => false).first
        if @notification.present?
          @notification.update!(resolved_status: true)
        end
        # return full trip to driver to maintain actual app status
        if current_user.driver?
          @trip = @trip_route_exception.trip
          @config_values = TripValidationService.driver_config_params(@trip)
          render 'api/v1/trips/show', status: 200
        else
          render 'api/v1/base/_success', status: 200
        end

      else
        @errors = @trip_route_exception.errors.full_messages
        render 'api/v1/base/_errors', status: 422
      end
    end

    protected
    def set_trip_route_exception
      @trip_route_exception = TripRouteException.find(params[:id])
    end
  end
end
