json.extract! trip_change_request, :id, :request_type, :reason, :request_state, :trip_type
json.new_date trip_change_request.new_date.to_i