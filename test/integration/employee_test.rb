require 'test_helper'

class EmployeeTest < ActionDispatch::IntegrationTest

  setup do
    @password = 'password0'
    @employee = employees(:employee)
    @other_employee = employees(:other_employee)
    @driver = drivers(:driver)
    @auth_headers = @employee.user.create_new_auth_token
    @auth_headers['Accept'] = Mime[:json]
  end

  test 'employee can sign in with username' do
    post '/api/v1/auth/sign_in',
         params: { username: @employee.username, password: @password, app: 'employee'},
         headers: { 'Accept' => Mime[:json]}

    user = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @employee.username, user[:username]
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee can sign in with email' do
    post '/api/v1/auth/sign_in',
         params: { username: @employee.email, password: @password, app: 'employee'},
         headers: { 'Accept' => Mime[:json]}

    user = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @employee.username, user[:username]
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee can sign in with phone' do
    post '/api/v1/auth/sign_in',
         params: { username: @employee.phone, password: @password, app: 'employee'},
         headers: { 'Accept' => Mime[:json]}

    user = JSON::parse(response.body, symbolize_names: true)

    assert_equal 200, response.status
    assert_equal @employee.username, user[:username]
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee gets an error when uses wrong credentials' do
    post '/api/v1/auth/sign_in',
         params: { username: @employee.username, password: 'hacked', app: 'employee'},
         headers: { 'Accept' => Mime[:json]}

    parsed_response = JSON::parse(response.body, symbolize_names: true)

    assert_equal 401, response.status
    assert_equal 'Invalid login credentials. Please try again.', parsed_response[:errors].first
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end


  test 'employee cannot sign in to driver app' do
    post '/api/v1/auth/sign_in',
         params: { username: @employee.username, password: @password, app: 'driver'},
         headers: { 'Accept' => Mime[:json]}
    message = JSON::parse(response.body, symbolize_names: true)

    assert_equal 403, response.status
    assert_equal 'Please use Employee app', message[:errors].first
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee can get own profile' do
    get "/api/v1/employees/#{@employee.user_id}", headers: @auth_headers
    employee = JSON::parse(response.body, symbolize_names: true)
    employee_schedules = @employee.employee_schedules.complete

    assert_equal 200, response.status
    assert_equal @employee.username, employee[:username]
    assert_equal true, employee[:emergency_contact].key?(:name)
    assert_equal true, employee[:emergency_contact].key?(:phone)

    assert_equal @employee.employer_name, employee[:employer][:name]
    assert_equal @employee.employer_phone, employee[:employer][:phone]

    employee[:schedule].each do |schedule|
      employee_schedule = employee_schedules.where(day: schedule[:day]).first
      assert_equal employee_schedule.check_in.strftime('%H:%M'), schedule[:check_in]
      assert_equal employee_schedule.check_out.strftime('%H:%M'), schedule[:check_out]
    end

    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee cannot get others profile' do
    get "/api/v1/employees/#{@other_employee.user_id}", headers: @auth_headers

    assert_equal 403, response.status
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee cannot get driver profile' do
    get "/api/v1/drivers/#{@driver.user_id}", headers: @auth_headers

    assert_equal 403, response.status
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee can update his emergency contacts' do
    patch "/api/v1/employees/#{@employee.user_id}",
          params: { employee: { emergency_contact_name: 'Mom', emergency_contact_phone: '9999999' } },
          headers: @auth_headers

    assert_equal 200, response.status
    assert_equal 'Mom', @employee.reload.emergency_contact_name
    assert_equal '9999999', @employee.reload.emergency_contact_phone
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

  test 'employee cannot update others emergency contacts' do
    patch "/api/v1/employees/#{@other_employee.user_id}",
          params: { employee: { emergency_contact_name: 'Dad', emergency_contact_name: '19999999' } },
          headers: @auth_headers

    assert_equal 403, response.status
    assert_equal Mime[:json], response.content_type
    assert_equal true, response.headers.include?('Server-Timestamp')
  end
end
