require 'test_helper'

class DriverDutiesTest < ActionDispatch::IntegrationTest

  setup do
    @driver = FactoryGirl.create(:driver)
    @vehicle = FactoryGirl.create(:vehicle)
  end


  test 'driver cannot enter invalid plate number' do
    post "/api/v1/drivers/#{@driver.user_id}/on_duty",
         params: { plate_number: 'QQQ' },
         headers: @driver.user.create_new_auth_token

    assert_equal 404, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)

    assert_equal false, response_body[:success]
    assert_equal false, response_body[:errors].empty?
  end

  test 'driver can go on duty' do
    post "/api/v1/drivers/#{@driver.user_id}/on_duty",
         params: { plate_number: @vehicle.plate_number },
         headers: @driver.user.create_new_auth_token

    assert_equal 200, response.status

    response_body = JSON::parse(response.body, symbolize_names: true)
    @driver = @driver.reload

    assert_equal 'on_duty', @driver.status

    assert_equal true, response_body[:success]
    assert_equal @vehicle.plate_number, response_body[:vehicle][:plate_number]
    assert_equal @vehicle.id, @driver.vehicle.id
  end


  test 'driver can go off duty' do
    get "/api/v1/drivers/#{@driver.user_id}/off_duty", headers: @driver.user.create_new_auth_token
    assert_equal 200, response.status
  end

end
