json.partial! 'api/v1/trips/trip'

if @trip.site
  json.site do
    json.partial! 'api/v1/sites/site', locals: { site: @trip.site }
  end
end

json.trip_routes @trip.trip_routes.order(:scheduled_route_order) do |trip_route|
  json.extract! trip_route, :id, :status, :bus_rider, :bus_stop_name, :bus_stop_address
  if trip_route.bus_rider
    json.bus_stop_location do
      json.latitude trip_route.employee.bus_trip_route.stop_latitude
      json.longitude trip_route.employee.bus_trip_route.stop_longitude
    end
  end
  json.route_order trip_route.scheduled_route_order
  json.eta trip_route.eta.to_i
  json.driver_arrived_date trip_route.driver_arrived_date.to_i
  json.move_to_next_step_date trip_route.move_to_next_step_date.to_i
  json.on_board_date trip_route.onboard_missed_date.to_i
  json.completed_date trip_route.completed_date.to_i
  json.pick_up_stop_address trip_route.pick_up_stop_address
  json.pick_up_stop_name trip_route.pick_up_stop_name
  json.pick_up_stop_lat trip_route.pick_up_stop_lat
  json.pick_up_stop_lng trip_route.pick_up_stop_lng
  json.pick_up_stop_lng trip_route.pick_up_stop_lng
  json.pick_up_stop_lng trip_route.pick_up_stop_lng
  json.pick_up_time trip_route.pick_up_time.to_i
  json.drop_off_time trip_route.drop_off_time.to_i
  json.employee do
    json.id trip_route.employee.user_id
    json.extract! trip_route.employee, :username, :f_name, :m_name, :l_name, :email, :phone, :home_address, :gender
    json.profile_picture trip_route.employee.full_avatar_url
    json.home_address_location do
      json.latitude trip_route.employee.home_address_latitude
      json.longitude trip_route.employee.home_address_longitude
    end
  end
end
