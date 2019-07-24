json.extract! employee_trip, :id, :trip_type, :status, :rating, :is_rating_screen_shown, :is_still_on_board_screen_shown
json.eta employee_trip.eta.to_i
json.schedule_date employee_trip.date.to_i
json.shift_date employee_trip.schedule_date.to_i
json.driver_arrive_date employee_trip.approximate_driver_arrive_date.to_i

json.emergency_contact do
  json.name employee_trip.employee.emergency_contact_name
  json.phone employee_trip.employee.emergency_contact_phone
end

json.driver do
  if employee_trip.trip.try(:driver)
    json.extract! employee_trip.trip.driver, :user_id, :username, :email, :f_name, :m_name, :l_name, :phone
    json.profile_picture employee_trip.trip.driver.full_avatar_url

    json.operating_organization do
      json.name employee_trip.trip.driver.operating_organization_name
      json.phone employee_trip.trip.driver.operating_organization_phone
    end
  end
end

if @vehicle
  json.vehicle do
    json.partial! 'api/v1/vehicles/vehicle'
  end
end

if (trip_change_request = employee_trip.latest_trip_change_request)
  json.trip_change_request do
    json.extract! trip_change_request, :id, :request_type, :reason, :request_state
    json.new_date trip_change_request.new_date.to_i
  end
end
