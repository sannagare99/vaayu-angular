json.extract! driver_request, :id, :request_type, :reason, :request_state, :trip_type
json.start_date driver_request.start_date.to_i
json.end_date driver_request.end_date.to_i
