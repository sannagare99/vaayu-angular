require 'test_helper'

class EmployeeUpcomingTripListTest < ActionDispatch::IntegrationTest

  setup do
    @employee = FactoryGirl.create(:employee)

    # create two upcoming trips
    @employee.employee_schedules.first.update_attributes( check_in: Time.now + 3.hours, check_out: Time.now + 6.hours)

    @employee_trips = @employee.employee_trips.upcoming
  end

  test 'unauthorized cannot get upcoming trip data' do
    get "/api/v1/employees/#{@employee.user_id}/upcoming_trips", headers: { 'Accept' => Mime[:json] }

    assert_equal 401, response.status
  end

  test 'employee can get his upcoming trips list' do
    get "/api/v1/employees/#{@employee.user_id}/upcoming_trips", headers: @employee.user.create_new_auth_token

    response_body = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @employee_trips.size, response_body[:upcoming_trips].size
  end

  test 'employee does not have upcoming trips' do
    @employee.employee_trips.upcoming.destroy_all

    get "/api/v1/employees/#{@employee.user_id}/upcoming_trips", headers: @employee.user.create_new_auth_token

    assert_equal 200, response.status
    response_body = JSON::parse(response.body, symbolize_names: true)

    assert_equal true, response_body[:upcoming_trips].empty?
  end
end
