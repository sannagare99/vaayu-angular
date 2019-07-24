require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then(/^User should see error message "([^"]*)" when trip not selected$/) do |arg|
  pending
end

And(/^Check correct date and time of request$/) do
  # click_link("Trips")
  # click_link("Ad Hoc Trips")
  formated_time = @next_trip_time.strftime("%H:%M %m/%d/%Y")
  employee =@user_employee.f_name + ' ' + @user_employee.l_name
  find('#employee-trip-request-table td:nth-child(1)').text.should eq formated_time
  find('#employee-trip-request-table td:nth-child(3)').text.should eq employee
  # find('#employee-adhoc-trip-table td:nth-child(8)').text.should eq @user_employee.phone

end

When(/^I select first trip in ad hocks trip tab$/) do
  sleep(3)
  page.first('#employee-adhoc-trip-table tbody tr .ch-row').click
  sleep(3)
end

Then(/^I should see my trip roaster$/) do
  find('#employee-trip-request-table td:nth-child(4)').text.should eq "FEFA6A57-5826-4C2D-9960-CC14C19563A2Created with sketchtool. " + @user_employee.f_name + ' ' + @user_employee.l_name
  formated_time = @next_trip_time.strftime("%m/%d/%Y")
  find('#employee-trip-request-table td:nth-child(2)').text.should eq formated_time
  #find('#employee-trip-request-table td:nth-child(6)').text.should eq @user_employee.phone
  #find('#employee-trip-request-table td:nth-child(7)').text.to_i.should eq @user_employee.entity_id

end

And(/^Employee create trip request "([^"]*)"$/) do |trip_type|
  @next_trip_time = (Time.now+3.hours)
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s

  test = HTTParty.post(host + "/api/v1/employee_trips",
                       {
                           :body => {"new_date": @next_trip_time.to_i, "trip_type": trip_type },
                           :headers => @auth_token_employee
                       })
end