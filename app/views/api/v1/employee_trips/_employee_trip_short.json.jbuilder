json.extract! employee_trip, :id, :trip_type, :status

json.approximate_driver_arrive_date employee_trip.approximate_driver_arrive_date.to_i
json.approximate_drop_off_date employee_trip.approximate_drop_off_date.to_i

unless employee_trip.trip_route.blank?
  json.actual_driver_arrive_date employee_trip.trip_route.on_board_date.to_i
  json.actual_drop_off_date employee_trip.trip_route.completed_date.to_i
end
