json.array!(@employee_trips) do |employee_trip|
  json.partial! 'api/v1/employee_trips/employee_trip_short', locals: { employee_trip: employee_trip }
end