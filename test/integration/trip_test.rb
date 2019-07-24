require 'test_helper'

class TripTest < ActionDispatch::IntegrationTest

  setup do
    @driver = FactoryGirl.create(:driver)
    @employee = FactoryGirl.create(:employee)

    # create two employee trips
    @employee.employee_schedules.first.update_attributes( check_in: Time.now + 3.hours, check_out: Time.now + 6.hours)

    @trip = FactoryGirl.create(:trip)
    @trip.planned_date = Time.now + 1.hour
    @trip.scheduled_date = Time.now + 1.hour
    @trip.driver = @driver
    @trip.assign_driver!
    @trip.assign_request_accepted!
  end

  test 'unauthorized cannot get upcoming driver trip data' do
    get "/api/v1/drivers/#{@driver.user_id}/upcoming_trip", headers: { 'Accept' => Mime[:json] }

    assert_equal 401, response.status

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end


  test 'employee can get his upcoming trip data' do
    get "/api/v1/employees/#{@employee.user_id}/upcoming_trip", headers: @employee.user.create_new_auth_token

    employee_trip = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal true, employee_trip[:schedule_date] > Time.now.to_i

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  # test 'get trip by id' do
  #   get "/api/v1/trips/#{@employee_trip.id}", headers: @driver.user.create_new_auth_token
  #
  #   employee_trip = JSON::parse(response.body, symbolize_names: true)
  #
  #   assert_equal 200, response.status
  #   assert_equal @employee_trip.id, employee_trip[:id]
  #
  #   assert_equal Mime[:json], response.content_type
  #   assert_equal true, response.headers.include?('Server-Timestamp')
  # end

  test 'driver does not have upcoming trip' do
    @driver.trips.upcoming.destroy_all

    get "/api/v1/drivers/#{@driver.user_id}/upcoming_trip", headers: @driver.user.create_new_auth_token

    assert_equal 200, response.status

    trip_data = JSON::parse(response.body, symbolize_names: true)

    assert_equal nil, trip_data[:trip]

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end


  test 'driver can see his upcoming trip' do
    get "/api/v1/drivers/#{@driver.user_id}/upcoming_trip", headers: @driver.user.create_new_auth_token

    assert_equal 200, response.status

    trip = JSON::parse(response.body, symbolize_names: true)

    assert_equal @driver.status, trip[:driver_status]
    assert_equal @trip.id, trip[:trip][:id]
    assert_equal true, trip[:trip].key?(:next_pickup_date)

  end

  # @TODO: add trip routes properly to the trip
  test 'driver can see trip by id' do
    get "/api/v1/trips/#{@trip.id}", headers: @driver.user.create_new_auth_token

    assert_equal 200, response.status
    trip = JSON::parse(response.body, symbolize_names: true)
    assert_equal true, trip.key?(:site)
    assert_equal @trip.trip_routes.size, trip[:trip_routes].size
    # is sorted properly
    assert_equal trip[:trip_routes], trip[:trip_routes].sort(&:scheduled_route_order)
  end

  test 'driver cannot see others trip by id' do
    other_trip = FactoryGirl.create(:trip)

    get "/api/v1/trips/#{other_trip.id}", headers: @driver.user.create_new_auth_token
    assert_equal 403, response.status
  end

  test 'driver can start the trip' do
    get "/api/v1/trips/#{@trip.id}/start", headers: @driver.user.create_new_auth_token

    assert_equal 200, response.status

    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal true, response_body[:success]
    assert_equal true, @trip.reload.start_date.present?


  end


end
