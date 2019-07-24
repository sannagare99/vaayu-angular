require File.expand_path(File.join(File.dirname(__FILE__), "../../", "support", "paths"))

def create_employees count,gender,random
  @employees = []
  @user_employees = []
  count.to_i.times do |index|
    gender = ['male','female'].sample if random
    u = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company, gender: gender,
      home_address: 'Karnik Road, Kalyan West, Syndicate, Thane, Maharashtra 421301')
    # puts u.to_json
    auth_token_employee = u.user.create_new_auth_token
    @employees << u
    @user_employees << User.find_by_email(auth_token_employee["uid"])
  end
end

def create_employees_nearby count,gender,random
  @employees = []
  @user_employees = []
  count.to_i.times do |index|
    gender = ['male','female'].sample if random
    if @home_address
      u = FactoryGirl.create(:employee, site: @site,
        employee_company: @employee_company, gender: gender, home_address: @home_address)
    else
      u = FactoryGirl.create(:employee, site: @site,
        employee_company: @employee_company, gender: gender)
      @home_address = u.home_address
    end
    # puts u.to_json
    auth_token_employee = u.user.create_new_auth_token
    @employees << u
    @user_employees << User.find_by_email(auth_token_employee["uid"])
    # puts User.find_by_email(auth_token_employee["uid"]).to_json
  end
end

Given(/^I create "([^"]*)" employees in database$/) do |count|
  create_employees(count,'female',true)
end

Given(/^Use Chrome driver for testing$/) do
  Capybara.register_driver :selenium do |app|
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 120
    Capybara::Selenium::Driver.new(app, browser: :chrome, http_client: client)
  end
end

Given(/^I create "([^"]*)" employees in database with same address$/) do |count|
  @home_address = nil
  create_employees_nearby(count,'female',true)
end

Given(/^I create "([^"]*)" male employees and "([^"]*)" female employees in database$/) do |male,female|
  create_employees(male,'male',false)
  create_employees(female,'female',false)
end

Given(/^I create employer shift manager in database$/) do
  u = FactoryGirl.create(:employer_shift_manager, employee_company: @employee_company)
end

Given(/^Filling database and login as employer using cookies$/) do
  step 'Filling database'
  if !@session_cookie
    step 'I am on "/"'
    step 'I am try to log in as employer'
  end
  step 'Get Cookies'
end

When(/^I click to "([^"]*)" calendar on "([^"]*)" date$/) do |calendar,date|
  sleep(1)
  case date
  when 'Today'
    date = Date.today.day
  when 'Tomorrow'
    date = Date.tomorrow.day
  else
    date = Date.today.day
  end
  # page.find(calendar).find('td', :text => date.to_s).click
  count = page.find(calendar).all('.available', :text => date.to_s).count
  page.find(calendar).all('.available', :text => date.to_s)[count-1].click
  sleep(1)
end

When(/^I click to "([^"]*)" calendar on "([^"]*)" date for regression$/) do |calendar,date|
  sleep(1)
  case date
  when 'Today'
    date = Date.today.day
  when 'Tomorrow'
    date = Date.tomorrow.day
  else
    date = Date.today.day
  end
  # page.find(calendar).find('td', :text => date.to_s).click
  count = page.find(calendar).all('.day', :text => date.to_s).count
  page.find(calendar).all('.day', :text => date.to_s)[count-1].click
  sleep(1)
end

Given(/^I create "([^"]*)" Manager in database$/) do |type|
  case type
  when 'Line'
    @new_manager = FactoryGirl.create(:line_manager, employee_company: @employee_company).user
  when 'Transport Desk'
    @new_manager = FactoryGirl.create(:transport_desk_manager, employee_company: @employee_company).user
  else
    @new_manager = FactoryGirl.create(:line_manager, employee_company: @employee_company).user
  end
  # puts @new_manager
end

Given(/^Start Console$/) do
  binding.pry
end

Given(/^Page Refreshed$/) do
  page.evaluate_script 'window.location.reload()'
end 

Then /^I should get a download with the filename "([^\"]*)"$/ do |filename|
   page.response_headers['Content-Disposition'].should include("filename=\"#{filename}\"")
end