require 'test_helper'

class DriverAcceptRejectTripRequestTest < ActionDispatch::IntegrationTest

  setup do
    @driver = FactoryGirl.create(:driver)
    @trip = FactoryGirl.create(:trip)

    @trip.driver = @driver
    @trip.assign_driver!

  end

  test 'get list of drivers income trip requests' do
    get "/api/v1/drivers/#{@driver.user_id}/last_trip_request", headers: @driver.user.create_new_auth_token

    assert_equal 200, response.status

    trip = JSON::parse(response.body, symbolize_names: true)

    assert_equal @trip.id, trip[:id]
    assert_equal false, trip[:assign_request_expired_date].blank?
  end

  test 'driver can accept trip' do
    get "/api/v1/trips/#{@trip.id}/accept_trip_request", headers: @driver.user.create_new_auth_token

    assert_equal 200, response.status

    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal true, response_body[:success]
    assert_equal @trip.id, response_body[:trip][:id]
  end

  test 'driver can reject trip' do
    get "/api/v1/trips/#{@trip.id}/decline_trip_request", headers: @driver.user.create_new_auth_token

    assert_equal 200, response.status

    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal true, response_body[:success]

  end

  test 'driver cannot accept expired trip' do
    @trip.assign_driver_request_expired!

    get "/api/v1/trips/#{@trip.id}/decline_trip_request", headers: @driver.user.create_new_auth_token

    assert_equal 422, response.status

    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal false, response_body[:success]
    assert_equal false, response_body[:errors].blank?

  end

end
