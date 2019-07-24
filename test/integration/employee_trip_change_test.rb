require 'test_helper'

class EmployeeTripTest < ActionDispatch::IntegrationTest

  setup do
    @employee = FactoryGirl.create(:employee)

    # create two upcoming trips
    @employee.employee_schedules.first.update_attributes( check_in: Time.now + 3.hours, check_out: Time.now + 6.hours)

    @employee_trip = @employee.closest_employee_trip
  end

  test 'employee can send trip cancel request' do
    post "/api/v1/employee_trips/#{@employee_trip.id}/cancel",
          params: { reason: 'emergency' },
          headers: @employee.user.create_new_auth_token

    assert_equal 200, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal true, response_body[:success]
    assert_not_nil response_body[:trip_change_request_id]

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee cannot send trip cancel request without reason specified' do
    post "/api/v1/employee_trips/#{@employee_trip.id}/cancel",
          headers: @employee.user.create_new_auth_token

    assert_equal 422, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal false, response_body[:success]
    assert_not_nil response_body[:errors]
  end

  test 'employee can send trip update request' do
    patch "/api/v1/employee_trips/#{@employee_trip.id}",
         params: { new_date: (Time.now + 9.hours).to_i, reason: 'emergency' },
         headers: @employee.user.create_new_auth_token

    assert_equal 200, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal true, response_body[:success]
    assert_not_nil response_body[:trip_change_request_id]

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee cannot send trip update request without specified date' do
    patch "/api/v1/employee_trips/#{@employee_trip.id}",
         params: { reason: 'emergency' },
         headers: @employee.user.create_new_auth_token

    assert_equal 422, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal false, response_body[:success]
    assert_not_nil response_body[:errors]
  end

  test 'employee cannot send trip update request without reason' do
    patch "/api/v1/employee_trips/#{@employee_trip.id}",
         params: { new_date: (Time.now + 9.hours).to_i },
         headers: @employee.user.create_new_auth_token

    assert_equal 422, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal false, response_body[:success]
    assert_not_nil response_body[:errors]
  end

  test 'employee cannot send trip update request with date in past' do
    patch "/api/v1/employee_trips/#{@employee_trip.id}",
         params: { new_date: (Time.now - 9.hours).to_i, reason: 'emergency' },
         headers: @employee.user.create_new_auth_token

    assert_equal 422, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal false, response_body[:success]
    assert_not_nil response_body[:errors]
  end

  test 'employee can request a new trip' do
    post '/api/v1/employee_trips/',
         params: { new_date: (Time.now + 9.hours).to_i, trip_type: 'check_in' },
         headers: @employee.user.create_new_auth_token

    assert_equal 200, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal true, response_body[:success]
    assert_not_nil response_body[:trip_change_request_id]

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee cannot send request a new trip with date in past' do
    post '/api/v1/employee_trips/',
          params: { new_date: (Time.now - 9.hours).to_i, trip_type: 'check_in' },
          headers: @employee.user.create_new_auth_token

    assert_equal 422, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal false, response_body[:success]
    assert_not_nil response_body[:errors]
  end

  test 'employee cannot request a new trip without date' do
    post '/api/v1/employee_trips/',
         params: { trip_type: 'check_in' },
         headers: @employee.user.create_new_auth_token

    assert_equal 422, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal false, response_body[:success]
    assert_not_nil response_body[:errors]

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee cannot request a new trip without trip type' do
    post '/api/v1/employee_trips/',
         params: { new_date: (Time.now + 9.hours).to_i },
         headers: @employee.user.create_new_auth_token

    assert_equal 422, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal false, response_body[:success]
    assert_not_nil response_body[:errors]

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee upcoming trip has trip request into in' do
    patch "/api/v1/employee_trips/#{@employee_trip.id}",
          params: { new_date: (Time.now + 9.hours).to_i, reason: 'emergency' },
          headers: @employee.user.create_new_auth_token

    assert_equal 200, response.status

    get "/api/v1/employees/#{@employee.user_id}/upcoming_trip", headers: @employee.user.create_new_auth_token

    employee_trip = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @employee_trip.id, employee_trip[:id]

    assert_equal true, employee_trip.key?(:trip_change_request)
    assert_equal true, employee_trip[:trip_change_request].key?(:new_date)
    assert_equal true, employee_trip[:trip_change_request].key?(:request_state)
    assert_equal true, employee_trip[:trip_change_request].key?(:reason)
    assert_equal true, employee_trip[:trip_change_request].key?(:request_type)

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end
end
