json.driver_status @driver.status

if @trip
  json.trip do
    json.partial! 'api/v1/trips/trip'
    json.next_pickup_date @trip.next_pickup_date.to_i
    json.assign_request_expired_date @trip.assign_request_expired_date.to_i
  end
end

if @vehicle
  json.vehicle do
    json.partial! 'api/v1/vehicles/vehicle'
  end
end

if @driver_request
  json.request do
    json.partial! 'api/v1/driver_requests/driver_request', locals: { driver_request: @driver_request }
  end
end
