json.partial! 'employee_trip', locals: { employee_trip: @employee_trip }

if @site
  json.site do
    json.partial! 'api/v1/sites/site', locals: { site: @site }
  end
end

if @config_values
  json.config_values @config_values
end

if @trip
  json.trip_route_id @employee_trip.trip_route.id

  json.trip do
    json.extract! @trip, :id, :status, :passengers, :book_ola, :bus_rider
    json.approximate_duration @trip.scheduled_approximate_duration
    json.approximate_distance @trip.scheduled_approximate_distance
    json.start_date @trip.start_date.to_i
    json.date @trip.scheduled_date.to_i
    json.approximate_trip_end_date @trip.approximate_trip_end_date.to_i

    json.trip_routes @trip.trip_routes do |trip_route|
      json.extract! trip_route, :id, :status, :bus_rider, :bus_stop_name, :bus_stop_address
      json.route_order trip_route.scheduled_route_order
      json.employee_name trip_route.employee.is_guard? ? "#{trip_route.employee.full_name} [Guard]" : trip_route.employee.full_name
      json.is_current_employee trip_route == @employee_trip.trip_route ? true : false
      json.eta trip_route.eta.to_i
      json.on_board_date trip_route.onboard_missed_date.to_i
      json.driver_arrived_date trip_route.driver_arrived_date.to_i
      json.completed_date trip_route.completed_date.to_i
      json.pick_up_stop_address trip_route.pick_up_stop_address
      json.pick_up_stop_name trip_route.pick_up_stop_name
      json.pick_up_time trip_route.pick_up_time.to_i
      json.drop_off_time trip_route.drop_off_time.to_i      
      json.move_to_next_step_date trip_route.move_to_next_step_date.to_i
      json.open_trip_route_exceptions trip_route.trip_route_exceptions.non_suspending.open do |trip_route_exception|
        json.partial! 'api/v1/trip_route_exceptions/trip_route_exception', locals: { trip_route_exception: trip_route_exception }
      end
    end
  end

end
