require 'test_helper'

class EmployeeTripRateTest < ActionDispatch::IntegrationTest

  setup do
    @employee_trip = FactoryGirl.create(:employee_trip)

    @employee = @employee_trip.employee
    @employee2 = FactoryGirl.create(:employee)
  end

  test 'employee can rate his trip' do
    post "/api/v1/employee_trips/#{@employee_trip.id}/rate",
         headers: @employee.user.create_new_auth_token,
         params: {
             rating: 3,
             rating_feedback: 'Lalala',
             trip_issues: %w(not_timely dirty)
         }


    assert_equal 200, response.status

    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal true, response_body[:success]

    assert_equal 3, @employee_trip.reload.rating
    assert_equal 'Lalala', @employee_trip.rating_feedback
    assert_equal %w(not_timely dirty), @employee_trip.employee_trip_issues.map(&:issue)
  end

  test 'employee can rate his trip with 5 and without issues' do
    post "/api/v1/employee_trips/#{@employee_trip.id}/rate",
         headers: @employee.user.create_new_auth_token,
         params: {
             rating: 5
         }


    assert_equal 200, response.status

    response_body = JSON::parse(response.body, symbolize_names: true)
    assert_equal true, response_body[:success]

    assert_equal 5, @employee_trip.reload.rating
    assert_equal true, @employee_trip.rating_feedback.blank?
    assert_equal true, @employee_trip.employee_trip_issues.empty?
  end

  test 'trip issues cannot be specified when trip rating is 5' do
    post "/api/v1/employee_trips/#{@employee_trip.id}/rate",
         headers: @employee.user.create_new_auth_token,
         params: {
             rating: 5,
             trip_issues: %w(not_timely dirty)
         }


    assert_equal 422, response.status
  end

  test 'employee cannot rate as 0' do
    post "/api/v1/employee_trips/#{@employee_trip.id}/rate",
         headers: @employee.user.create_new_auth_token,
         params: {
             rating: 0
         }


    assert_equal 422, response.status
  end

  test 'unauthorized cannot rate trip' do
    post "/api/v1/employee_trips/#{@employee_trip.id}/rate"
    assert_equal 401, response.status
  end

  test 'employee cannot rate others trip' do
    post "/api/v1/employee_trips/#{@employee_trip.id}/rate", headers: @employee2.user.create_new_auth_token
    assert_equal 403, response.status
  end

  test 'trip cannot be rated twice' do
    post "/api/v1/employee_trips/#{@employee_trip.id}/rate",
         headers: @employee.user.create_new_auth_token,
         params: {
             rating: 5
         }
    assert_equal 200, response.status

    post "/api/v1/employee_trips/#{@employee_trip.id}/rate",
         headers: @employee.user.create_new_auth_token,
         params: {
             rating: 3,
             trip_issues: [
                 { issue: 'not_timely' },
                 { issue: 'dirty' }
             ]
         }
    assert_equal 422, response.status
  end

end
