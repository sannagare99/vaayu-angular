require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

When(/^I change avatar$/) do
  # page.execute_script "$('.file-wrap-block input').attr('type', '')"
  # binding.pry

  attach_file('input[name="fileinput_widget"]', 'features/images/me.jpg', make_visible: true)
  find('input[name="fileinput_widget"]')
end

And(/^I am try to log in whith username "([^\"]*)" and password "([^\"]*)"$/) do |name, pass|
  page.find("#user_username").set(name)
  sleep(1)
  page.find("#user_password").set(pass)
  sleep(1)
  page.find('.btn-primary').click
end

And(/^send request$/) do
  @user_employee = User.find_by_email ("user1@n3wnormal.com")
  @auth_token = @user_employee.create_new_auth_token
end

Given(/^I am logout$/) do
  sleep(2)
  page.find('.profile-nav .dropdown-toggle').click
  sleep(10)
  page.find('.profile-nav .dropdown-menu li:nth-child(3) a').click
end
