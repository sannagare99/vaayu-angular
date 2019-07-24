class TripLocationsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_trip
  def index
    @employee_trip = []
    if params[:employee_trip_id].present?
      @employee_trip = EmployeeTrip.find_by_prefix(params[:employee_trip_id])
    end

    @trip_locations = @trip.trip_location.order("time ASC")
    
    if !@trip.start_date.blank?
      @trip_locations = @trip_locations.where('time >= ?', @trip.start_date).order("time asc")
    end

    if !@trip.completed_date.blank?
      @trip_locations = @trip_locations.where('time <= ?', @trip.completed_date).order("time asc")
    end

    if params[:employee_trip_id].present?
      render json: {'trip_locations': @trip_locations, 'trip': @trip, 'employee_trip': @employee_trip, 'approximate_driver_arrive_date': @employee_trip&.approximate_driver_arrive_date, 'approximate_drop_off_date': @employee_trip&.approximate_drop_off_date}
    else
      render json: {'trip_locations': @trip_locations, 'trip': @trip}
    end
  end

  def set_trip
    @trip = Trip.find_by_prefix(params[:id])
  end 
end
