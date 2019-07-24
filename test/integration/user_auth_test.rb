require 'test_helper'

class UserAuthTest < ActionDispatch::IntegrationTest

  setup do
    @driver = drivers(:driver)
    @employee = employees(:employee)
  end

  test 'user can login with username' do
    post "/api/v1/auth/sign_in", params: { username: @employee.username, password: 'password0', app: 'employee'}, headers: { 'Accept' => Mime[:json] }

    user = JSON::parse(response.body, symbolize_names: true)
    assert_equal 200, response.status
    assert_equal @employee.username, user[:username]
    assert_equal Mime[:json], response.content_type
  end

  test 'html returned to non-api part' do
    get '/logistics_companies'
    assert_equal Mime[:html], response.content_type
  end

  test 'user can login with email' do
    post "/api/v1/auth/sign_in", params: { username: @employee.email, password: 'password0', app: 'employee' }, headers: { 'Accept' => Mime[:json]}

    user = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @employee.username, user[:username]
    assert_equal Mime[:json], response.content_type
  end

  test 'user can login with phone' do
    post "/api/v1/auth/sign_in", params: { username: @employee.phone, password: 'password0', app: 'employee'}, headers: { 'Accept' => Mime[:json]}

    user = JSON::parse(response.body, symbolize_names: true)
    assert_equal 200, response.status
    assert_equal @employee.username, user[:username]
    assert_equal Mime[:json], response.content_type
  end

  test 'driver can login only in driver app' do
    post '/api/v1/auth/sign_in', params: { username: @driver.username, password: 'password3', app: 'driver' }, headers: { 'Accept' => Mime[:json]}

    driver = JSON::parse(response.body, symbolize_names: true)
    assert_equal 200, response.status
    assert_equal 'driver', driver[:role]
    assert_equal Mime[:json], response.content_type
  end
end
