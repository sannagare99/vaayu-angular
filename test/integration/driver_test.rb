require 'test_helper'

class DriverTest < ActionDispatch::IntegrationTest

  setup do
    @password = 'password3'
    @driver = drivers(:driver)
    @employee = employees(:employee)
    @auth_headers = @driver.user.create_new_auth_token
    @auth_headers['Accept'] = Mime[:json]
  end

  test 'driver can sign in with username' do
    post '/api/v1/auth/sign_in',
         params: { username: @driver.username, password: @password, app: 'driver'},
         headers: { 'Accept' => Mime[:json]}

    user = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @driver.username, user[:username]
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'driver can sign in with email' do
    post '/api/v1/auth/sign_in',
         params: { username: @driver.email, password: @password, app: 'driver'},
         headers: { 'Accept' => Mime[:json]}

    user = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @driver.username, user[:username]
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'driver can sign in with phone' do
    post '/api/v1/auth/sign_in',
         params: { username: @driver.phone, password: @password, app: 'driver'},
         headers: { 'Accept' => Mime[:json]}

    user = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @driver.username, user[:username]
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'driver gets an error when uses wrong credentials' do
    post '/api/v1/auth/sign_in',
         params: { username: @driver.username, password: 'hacked', app: 'driver'},
         headers: { 'Accept' => Mime[:json]}

    parsed_response = JSON::parse(response.body, symbolize_names: true)

    assert_equal 401, response.status
    assert_equal 'Invalid login credentials. Please try again.', parsed_response[:errors].first
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end


  test 'driver cannot sign in to employee app' do
    post '/api/v1/auth/sign_in',
         params: { username: @driver.username, password: @password, app: 'employee'},
         headers: { 'Accept' => Mime[:json]}
    message = JSON::parse(response.body, symbolize_names: true)

    assert_equal 403, response.status
    assert_equal 'Please use Driver app', message[:errors].first
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'driver can get own profile' do
    get "/api/v1/drivers/#{@driver.user_id}", headers: @auth_headers
    driver = JSON::parse(response.body, symbolize_names: true)
    assert_equal 200, response.status
    assert_equal @driver.username, driver[:username]

    assert_equal true, driver[:operating_organization].key?(:name)
    assert_equal true, driver[:operating_organization].key?(:phone)

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'driver cannot get employee profile' do
    get "/api/v1/employees/#{@employee.user_id}", headers: @auth_headers

    assert_equal 403, response.status
    assert_equal Mime[:json], response.content_type
  end

  test 'unauthorized cannot get driver profile' do
    get "/api/v1/drivers/#{@driver.user_id}", headers: { 'Accept' => Mime[:json] }
    assert_equal 401, response.status
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end
end
