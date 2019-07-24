require File.expand_path(File.join(File.dirname(__FILE__), "../../", "support", "paths"))

Given(/^Employee Create Trip request$/) do
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s
  @time = (Time.now + 4.hour)
  puts HTTParty.post(host + "/api/v1/employee_trips",
                                     {
                                         :body => {"trip_type": "check_in", "new_date": @time.to_i},
                                         :headers => @auth_token_employee
                                     })
end

Given(/^Employee Trip Request accepted$/) do
  page.all('.update_request')[0]&.click
end

Then(/^I should see API Employee Trip Requests for "([^"]*)"$/) do |trip_type|
  employee = Employee.last
  find('#employee-trip-request-table td:nth-child(3)').text.include?(employee.f_name + ' ' + employee.l_name).should be true
  formated_time = @time.strftime("%H:%M %m/%d/%Y")
  find('#employee-trip-request-table td:nth-child(1)').text.should eq formated_time
  gender_display = (employee.gender == 'male')? 'M':'F'
  find('#employee-trip-request-table td:nth-child(4)').text.should eq gender_display
end
