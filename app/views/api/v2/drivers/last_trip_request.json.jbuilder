if @trip
  json.partial! 'api/v1/trips/trip'
  json.assign_request_expired_date @trip.assign_request_expired_date.to_i
end
