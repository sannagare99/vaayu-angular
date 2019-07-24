json.success true
json.driver_request_id @driver_request.id
json.partial! 'api/v1/driver_requests/driver_request', locals: { driver_request: @driver_request }
