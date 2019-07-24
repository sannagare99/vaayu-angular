json.upcoming_trips(@employee_trips) do |employee_trip|
  json.partial! 'api/v1/employee_trips/employee_trip', locals: { employee_trip: employee_trip }
end

json.new_trip_requests(@employee_trip_change_requests) do |trip_change_request|
  json.partial! 'api/v1/trip_change_requests/trip_change_request', locals: { trip_change_request: trip_change_request }
end

