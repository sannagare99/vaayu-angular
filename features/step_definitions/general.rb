require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given(/^I am on "(.+)"$/) do |page_name|
  page.visit(page_name)
end

Then(/^Wait until find elem "([^"]*)"$/) do |arg|
  sleep(2)
  page.find(arg)
end

When(/^I wait for "([^"]*)" seconds$/) do |time|
  sleep(time.to_i)
end

Given(/^Filling database$/) do
  step 'I create companies in database'
  step 'I create site in database'
  step 'I create employer in database'
  step 'I create employee in database'
  step 'I create driver in database'
  step 'I create operator in database'
end

Then(/^I should see "([^"]*)"$/) do |arg|
  page.has_content?(arg).should be true or false
end

Then(/^I should see "([^"]*)" on an alert$/) do |arg|
  page.driver.browser.switch_to.alert.text.include?(arg).should be true
end

When(/^I click to "([^"]*)"$/) do |arg|
  sleep(2)
  page.find(arg).click
  sleep(2)
end

When(/^I click link "([^"]*)"$/) do |arg|
  click_link(arg)
  sleep(4)
end

And(/^I fill "([^"]*)" field with text "([^"]*)"$/) do |arg1, arg2|
  page.find(arg1).set(arg2)
  sleep(1)
end

And(/^I fill "([^"]*)" field with employer's email$/) do |arg|
  page.find(arg).set(@user_employer.email)
  sleep(1)
end

And(/^In "([^"]*)" I should see "([^"]*)"$/) do |arg1, arg2|
  expect(find(arg1).text).to eq arg2
end

Given(/^I create companies in database$/) do
  @logistics_company = FactoryGirl.create(:logistics_company)
  @employee_company = FactoryGirl.create(:employee_company, logistics_company: @logistics_company)
end

Given(/^I create site in database$/) do
  @site = FactoryGirl.create(:site, employee_company: @employee_company)
end

Given(/^I create employer in database$/) do
  u = FactoryGirl.create(:employer, employee_company: @employee_company)
  @employer_id = u.id
  @user_employer = User.find_by_id(@employer_id)
  # @auth_token_employer = @user_employer.create_new_auth_token
end

Given(/^I create driver in database$/) do
  @driver = FactoryGirl.create(:driver, site: @site, logistics_company: @logistics_company)
  @auth_token_driver = @driver.user.create_new_auth_token
end

Given(/^I create operator in database$/) do
  @operator = FactoryGirl.create(:operator)
end

# Given(/^Driver check in request$/) do
#   host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s
#
#   @check_in_response = HTTParty.post(host + "/api/v1/drivers/#{@driver.user.id}/on_duty",
#                        {
#                            :body => {"plate_number": @driver.vehicle.plate_number},
#                            :headers => @auth_token_driver
#                        })
# end

Given(/^I create employee in database$/) do
  u = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company)
  @auth_token_employee = u.user.create_new_auth_token
  @user_employee = User.find_by_email(@auth_token_employee["uid"])
end

When(/^I am try to log in as operator/) do
  sleep(1)
  page.find("#user_username").set(@operator.email)
  sleep(1)
  page.find("#user_password").set('n3wnormal')
  sleep(1)
  page.find('.btn-primary').click
end

When(/^Buttons "([^"]*)" pressed$/) do |arg|
  click_button(arg)
  sleep(4)
end

Then(/^debug$/) do
  binding.pry
end

And(/^I set on "([^"]*)" value "([^"]*)"$/) do |arg1, arg2|
  sleep(2)
  find(arg1).find(:option, arg2).select_option
  sleep(2)
end

Then(/^Wait for modal "([^"]*)"$/) do |modal_title|
  sleep(2)
  page.find('.modal').find('.modal-title').text.should eq modal_title
end

When(/^I close modal "([^"]*)"$/) do |modal_selector|
  page.find(modal_selector).find('.modal-header').find('.close').click
end

Then(/^I should not see element "([^"]*)"$/) do |element|
  expect(page).to have_no_css(element)
end

And(/^I set avatar$/) do
  attach_file('fileinput_widget', Rails.root.join('features/image_for_upload.jpg'))
end

And(/^I select date table$/) do
  #first('.form-control').click
  page.find('#employee-trip-request').find('form').find('.date-filter').first('li').click
  sleep(4)
end

Given(/^I create male employee in database$/) do
  @male_employee = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company)
  @auth_token_male_employee = @male_employee.user.create_new_auth_token
end

Given(/^I create female employee in database$/) do
  @female_employee = FactoryGirl.create(:employee, gender: 0, site: @site, employee_company: @employee_company)
  @auth_token_female_employee = @female_employee.user.create_new_auth_token
 end

And(/^I fill "([^"]*)" field with invalid email$/) do |arg|
  page.find(arg).set("random_invalid@mail.com")
  sleep(1)
end
