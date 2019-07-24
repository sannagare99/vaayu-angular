json.extract! @trip, :id, :status, :trip_type, :passengers, :book_ola, :bus_rider
json.approximate_duration @trip.scheduled_approximate_duration
json.approximate_distance @trip.scheduled_approximate_distance
json.start_date @trip.start_date.to_i
json.driver_should_start_trip_time @trip.driver_should_start_trip_time.to_i
json.driver_should_start_trip_timestamp @trip.driver_should_start_trip_timestamp.to_i
json.date @trip.scheduled_date.to_i
json.shift_date @trip&.employee_trips&.first&.date.to_i
json.approximate_trip_end_date @trip.approximate_trip_end_date.to_i
json.suspended @trip.suspended?
json.suspending_trip_route_exceptions(@trip.trip_route_exceptions.unresolved_suspending) do |trip_route_exception|
  json.partial! 'api/v1/trip_route_exceptions/trip_route_exception', locals: { trip_route_exception: trip_route_exception }
  json.extract! trip_route_exception, :trip_route_id
end
if @trip.completed?
  json.extract! @trip, :real_duration, :average_rating
  json.completed_date @trip.completed_date.to_i
end
if @config_values
  json.config_values @config_values
end
