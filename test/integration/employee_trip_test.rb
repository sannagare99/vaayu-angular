require 'test_helper'

class EmployeeTripTest < ActionDispatch::IntegrationTest

  setup do
    @employee = FactoryGirl.create(:employee)

    # create two upcoming trips
    @employee.employee_schedules.first.update_attributes( check_in: Time.now + 3.hours, check_out: Time.now + 6.hours)

    @employee_trip = @employee.closest_employee_trip
  end

  test 'unauthorized cannot get upcoming trip data' do
    get "/api/v1/employees/#{@employee.user_id}/upcoming_trip", headers: { 'Accept' => Mime[:json] }

    assert_equal 401, response.status

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee can get his upcoming trip data' do
    get "/api/v1/employees/#{@employee.user_id}/upcoming_trip", headers: @employee.user.create_new_auth_token

    employee_trip = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @employee_trip.id, employee_trip[:id]

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'get trip by id' do
    get "/api/v1/employee_trips/#{@employee_trip.id}", headers: @employee.user.create_new_auth_token

    employee_trip = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @employee_trip.id, employee_trip[:id]

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee does not have upcoming trip' do
    @employee.employee_trips.upcoming.destroy_all

    get "/api/v1/employees/#{@employee.user_id}/upcoming_trip", headers: @employee.user.create_new_auth_token

    assert_equal 200, response.status
    assert_equal '{}', response.body

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end
end
