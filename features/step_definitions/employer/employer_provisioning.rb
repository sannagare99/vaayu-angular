require File.expand_path(File.join(File.dirname(__FILE__), "../../", "support", "paths"))
require 'sidekiq/testing'
# Common

def form_field_class field_type
  case field_type
  when 'First Name'
    '.user_f_name'
  when 'Last Name'
    '.user_l_name'
  when 'Email'
    '.user_email'
  when 'Phone'
    '.user_phone'
  when 'Company'
    '.user_entity_employee_company'
  when 'Gender'
    '.user_entity_gender'
  when 'Site'
    '.user_entity_site'
  when 'Zone'
    '.user_entity_zone'
  when 'Home Address'
    '.user_entity_home_address'
  when 'Name'
    '.shift_name'
  when 'Start Time'
    '.shift_start_time'
  when 'End Time'
    '.shift_end_time'
  else
    '.user_f_name'
  end
end

Given(/^Redirect to Provisioning page$/) do
  step 'I am on "/provisioning"'
end

Given(/^Go to Provisioning page by setting cookies$/) do
  step 'Filling database'
  if !@session_cookie
    step 'I am on "/"'
    step 'I am try to log in as employer'
  end
  step 'Get Cookies'
  step 'I am on "/provisioning"'
end

Given(/^Go to Provisioning page "([^"]*)" tab$/) do |tab_selector|
  page.find('.nav-tabs').find(tab_selector).click
end

Then(/^I should see error for "([^"]*)" field as "([^"]*)"$/) do |field_type,error|
  sleep(1)
  page.find(form_field_class(field_type)).has_content?(error).should be true
end

# Employee Creation
def setup_new_employee duplicate_field
  if duplicate_field.length > 0
    u = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company)
    @auth_token_employee = u.user.create_new_auth_token
    @former_employee = User.find_by_email(@auth_token_employee["uid"])
  end
  # get fake data for new employee
  @new_employee = {}
  @new_employee['first_name'] = Faker::Name.first_name
  @new_employee['last_name'] = Faker::Name.last_name
  @new_employee['user_email'] = (duplicate_field != 'Email')?(Faker::Internet.email):(@former_employee.email)
  @new_employee['phone'] = (duplicate_field != 'Phone')?(Faker::Number.number(10)):(@former_employee.phone)
  @new_employee['address'] = 'Amar Flats, Yesvantpur Industrial Suburb, Yeshwanthpur, Bengaluru, Karnataka 560086'
end


def fill_employee_form *remove_fields
  # Select Site 
  page.find('#user_entity_attributes_site_id').find(:xpath, 'option[2]').select_option if (!remove_fields.include?  'Site')
  sleep(2)
  # select address
  if (!remove_fields.include?  'Home Address')
    page.find('#user_entity_attributes_home_address').set(@new_employee['address'])
    sleep(1)
    page.find('#user_m_name').set('')
    sleep(4)
  end
  page.find('#user_phone').set(@new_employee['phone']) if (!remove_fields.include?  'Phone')
  sleep(1)
  page.find('#user_f_name').set(@new_employee['first_name']) if (!remove_fields.include?  'First Name')
  sleep(3)
  page.find('#user_email').set(@new_employee['user_email']) if (!remove_fields.include?  'Email')
  sleep(1)
  page.find('#user_l_name').set(@new_employee['last_name']) if (!remove_fields.include?  'Last Name')
  sleep(3)
  
  # select company
  page.find('#user_entity_attributes_employee_company_id').find(:xpath, 'option[2]').select_option if (!remove_fields.include?  'Company')
  sleep(1)
  # select gender
  page.find('#user_entity_attributes_gender').find(:xpath, 'option[2]').click if (!remove_fields.include?  'Gender')
  sleep(1)
  # select zone
  page.find('#user_entity_attributes_zone_id').find(:xpath, 'option[2]').select_option if (!remove_fields.include?  'Zone')
  sleep(1)
end

Then(/^Wait for employer form "([^"]*)"$/) do |field_label|
  sleep(2)
  page.find('#form-employees').find('.field-label').text.should eq field_label
end

When(/^I submit new employee form$/) do
  page.find('#form-employees').find('.btn-primary').click
  sleep(4)
end

When(/^I cancel new employee form$/) do
  page.find('#form-employees').find('.cancel').click
  sleep(4)
end

Given(/^Fill form new employee data$/) do
  # get fake data for new employee
  setup_new_employee ''
  fill_employee_form ''
end

Then(/^I should see existing employee$/) do
  page.find('#employees-table .employer_edit').text.should eq @user_employee.f_name + ' ' + @user_employee.l_name
#  page.find('#employees-table td:nth-child(3)').text.should eq @user_employee.email
  page.find('#employees-table td:nth-child(4)').text.should eq @user_employee.phone
end

Given(/^Fill form new Employee data without "([^"]*)"$/) do |remove_field|
  # get fake data for new employee
  setup_new_employee ''
  fill_employee_form remove_field
end

Given(/^Fill form new Employee data with duplicate "([^"]*)"$/) do |duplicate_field|
  # get fake data for new employee
  setup_new_employee duplicate_field
  fill_employee_form ''
end

Then(/^I should not see new employee$/) do
  sleep(2)
  page.all('#employees-table tbody tr').count.should eq 1
end

# Shift Creation
def setup_new_shift 
  # get fake data for new shift
  @new_shift = {}
  @new_shift['name'] = 'Afternoon Schedule'
  @new_shift['start_time'] = '10:00'
  @new_shift['end_time'] = '14:00'
end


def fill_shift_form *remove_fields
  page.find('#shift_name').set(@new_shift['name']) if (!remove_fields.include?  'Name')
  sleep(1)
  page.find('#shift_start_time').set(@new_shift['start_time']) if (!remove_fields.include?  'Start Time')
  sleep(1)
  page.find('#shift_end_time').set(@new_shift['end_time']) if (!remove_fields.include?  'End Time')
  sleep(1)
end

When(/^I submit new shift form$/) do
  page.find('#form-shifts').find('.btn-primary').click
  sleep(4)
end

When(/^I cancel new shift form$/) do
  page.find('#form-shifts').find('.cancel').click
  sleep(4)
end

Given(/^Fill form new shift data$/) do
  # get fake data for new shift
  setup_new_shift
  fill_shift_form ''
end

Then(/^I should see existing shift$/) do
  page.find('#shifts-table .employer_edit').text.should eq @user_shift.f_name + ' ' + @user_shift.l_name
#  page.find('#shifts-table td:nth-child(3)').text.should eq @user_shift.email
  page.find('#shifts-table td:nth-child(4)').text.should eq @user_shift.phone
end

Given(/^Fill form new shift data without "([^"]*)"$/) do |remove_field|
  # get fake data for new shift
  setup_new_shift
  fill_shift_form remove_field
end

Then(/^I should not see new shift$/) do
  sleep(2)
  page.all('#shifts-table tbody tr')[0].text.should eq 'No result'
end

Then(/^I should see new shift$/) do
  sleep(2)
  page.all('#shifts-table tbody tr').count.should eq 1
end

# Manager Creations
def form_id manager_type
  case manager_type
  when 'Line'
    '#form-line_managers'
  when 'Shift'
    '#form-employer_shift_managers'
  when 'Transport Desk'
    '#form-transport_desk_managers'
  when 'Guard'
    '#form-guards'
  else
    '#form-employees'
  end
end

def table_id manager_type
  case manager_type
  when 'Line'
    '#line-managers-table'
  when 'Shift'
    '#employer-shift-managers-table'
  when 'Transport Desk'
    '#transport-desk-managers-table'
  when 'Guard'
    '#guards-table'
  else
    '#employees-table'
  end
end

def setup_new_manager duplicate_field
  if duplicate_field.length > 0
    u = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company)
    @auth_token_employee = u.user.create_new_auth_token
    @former_employee = User.find_by_email(@auth_token_employee["uid"])
  end
  # get fake data for new manager
  @new_manager = {}
  @new_manager['first_name'] = Faker::Name.first_name
  @new_manager['user_email'] = (duplicate_field != 'Email')?(Faker::Internet.email):(@former_employee.email)
  @new_manager['phone'] = (duplicate_field != 'Phone')?(Faker::Number.number(10)):(@former_employee.phone)
  @new_manager['last_name'] = Faker::Name.last_name
end

def fill_manager_form remove_field
  page.find('#user_phone').set(@new_manager['phone']) if (remove_field !='Phone')
  sleep(1)
  page.find('#user_email').set(@new_manager['user_email']) if (remove_field !='Email')
  sleep(1)
  page.find('#user_f_name').set(@new_manager['first_name']) if (remove_field !='First Name')
  sleep(1)
  page.find('#user_l_name').set(@new_manager['last_name']) if (remove_field !='Last Name')
  sleep(2)

  # select company
  if (remove_field !='Company')
    page.find('#user_entity_attributes_employee_company_idSelectBoxIt').click
    page.find('#user_entity_attributes_employee_company_idSelectBoxItOptions').find(:xpath, 'li[1]').select_option
    sleep(1)
  end
end

Given(/^Fill form new manager data$/) do
  # get fake data for new employee
  setup_new_manager ''
  fill_manager_form ''
end

Given(/^Fill form new manager data without "([^"]*)"$/) do |remove_field|
  # get fake data for new employee
  setup_new_manager ''
  fill_manager_form remove_field
end

Given(/^Fill form new manager data with duplicate "([^"]*)"$/) do |duplicate_field|
  # get fake data for new employee
  setup_new_manager duplicate_field
  fill_manager_form ''
end

Then(/^Wait for "([^"]*)" Manager form attributes$/) do |manager_type|
  page.find(form_id(manager_type)).find('.field-label').text.should eq "#{manager_type} Manager attributes:"
end


When(/^I submit new "([^"]*)" manager form$/) do |manager_type|
  page.find('.content-body').find('.btn-primary').click
  sleep(4)
end

Then(/^I should not see new "([^"]*)" manager$/) do |manager_type|
  page.all(table_id(manager_type)+' tbody tr').count.should eq 1
end

Then(/^I should see new "([^"]*)" manager$/) do |manager_type|
  sleep(2)
  # puts table_id(manager_type)
  page.find(table_id(manager_type)+' tr:nth-child(1) .edit').text.should eq @new_manager['first_name'] + ' ' + @new_manager['last_name']
  email_num = (manager_type=='Shift')?5:4
  page.find(table_id(manager_type)+" tr:nth-child(1) td:nth-child(#{email_num})").text.should eq @new_manager['user_email']
  phone_num = (manager_type=='Shift')?6:5
  page.find(table_id(manager_type)+" tr:nth-child(1) td:nth-child(#{phone_num})").text.should eq @new_manager['phone']
end

When(/^I click on Edit List for Line Manager "([^"]*)"$/) do |count|
  sleep(1)
  # puts page.all('#line-managers-table tbody tr')[count.to_i - 1]
  page.all('#line-managers-table tbody tr')[count.to_i - 1].find('td:nth-child(6) a').click
  sleep(4)
end

When(/^I select "([^"]*)" employees from employee list$/) do |count|
  count.to_i.times do |index|
    page.all('.employee-list-table tbody tr')[index+1].find('input').click
  end
  sleep(1)
end

When(/^I deselect "([^"]*)" employees from employee list$/) do |count|
  count.to_i.times do |index|
    page.all('.employee-list-table tbody tr')[index+1].find('input').click
  end
  sleep(1)
end

When(/^I should see "([^"]*)" employees selected in employee list$/) do |count|
  selected = 0
  page.all('.employee-select-check').each do |input|
    selected = selected + input.value.to_i
  end
  count.to_i.should eq selected
end

When(/^I fill Search Input with "([^"]*)" name of Employee "([^"]*)"$/) do |match,index|
  emp = Employee.find(index.to_i)
  case match
  when 'Partial'
    search = emp.user.f_name[0..2]
  when 'Complete'
    search = emp.user.f_name + ' ' + emp.user.l_name
  else
    search = emp.user.f_name + ' ' + emp.user.l_name
  end
  page.find('#employee_list_search').set(search)
end

Then(/^I should see "([^"]*)" employees with name matched with Search Input$/) do |count|
  page.find('.employee-list-table tbody').all('tr').count.should eq count.to_i
  search = page.find('#employee_list_search').text
  page.find('.employee-list-table tbody').all('tr').each do |emp|
    expect(emp.find('td:nth-child(1)').text).to include(search)
  end
end

# Security Guards
Given(/^Fill form new guard data$/) do
  # get fake data for new employee
  setup_new_employee ''
  fill_employee_form 'Zone'
end

Given(/^Fill form new guard data without "([^"]*)"$/) do |remove_field|
  # get fake data for new employee
  setup_new_employee ''
  fill_employee_form remove_field,'Zone'
end

Given(/^Fill form new guard data with duplicate "([^"]*)"$/) do |duplicate_field|
  # get fake data for new employee
  setup_new_employee duplicate_field
  fill_employee_form 'Zone'
end

Then(/^Wait for Guard form attributes$/) do
  page.find(form_id('Guard')).find('.field-label').text.should eq "Guard attributes:"
end

When(/^I submit new guard form$/) do
  page.find('.content-body').find('.submit-button').click
  sleep(4)
end

Then(/^I should not see new guard$/) do
  page.all(table_id('Guard')+' tbody tr td').count.should eq 1
end

Then(/^I should see new guard$/) do
  page.find(table_id('Guard')+' tbody tr:nth-child(1) td:nth-child(2)').text.should eq @new_employee['first_name'] + ' ' + @new_employee['last_name']
  page.find(table_id('Guard')+" tbody tr:nth-child(1) td:nth-child(4)").text.should eq @new_employee['phone']
end

#Zone
When(/^Fill new zone form$/) do
  @zone_name = Faker::Number.between(2, 9)
  page.find('#zone_name').set(@zone_name)
  sleep(2)
end

Given(/^Fill incorrect new zone form$/) do
  @zone_name = Faker::Lorem.word
  page.find('#zone_name').set(@zone_name)
  sleep(2)
end

Then(/^I should see new zone$/) do
  sleep(2)
  page.all('#zones-table tr').count.should eq 3
  page.find('#zones-table tr:nth-child(2) .edit').text.should eq @zone_name.to_s
end

When(/^I try delete new zone$/) do
  sleep(2)
  page.find('#zones-table tr:nth-child(2) .editor_remove').click
  sleep(2)
end

Then(/^I should not see new zone$/) do
  sleep(2)
  page.all('#zones-table tr').count.should eq 2
end

When(/^I submit new zone form$/) do
  page.find('.content-body').find('.btn-primary').click
  sleep(4)
end

When(/^I reset password of Shift Manager$/) do
  user = EmployerShiftManager.last.user
  raw, enc = Devise.token_generator.generate(user.class, :reset_password_token)
  user.reset_password_token   = enc
  user.reset_password_sent_at = Time.now.utc
  user.save(validate: false)
  url = "/users/password/edit?reset_password_token=#{raw}"
  page.visit(url)
end

When(/^I fill password fields with new passwords$/) do
  page.find('#user_password').set('password')
  page.find('#user_password_confirmation').set('password')
  page.all('.btn-primary')[0].click
end

# Issue.528
When(/^Upload Excel of Employee data$/) do
  Sidekiq::Worker.clear_all
  attach_file('ingest_job[file]', Rails.root.join('features/excels/Ingest Excel Format.xlsx'))
  sleep(2)
  page.find('.modal-content .btn-primary').click
  sleep(2)
  sleep(3)
  Sidekiq::Worker.drain_all
  sleep(5)
  page.find('#employees-provisioned-count').text.should eq '1'
  page.find('.modal-content .btn-primary').click
end

Then(/^I should see correct format of phone of new employee of employee excel$/) do
  page.find('#employees-table tr:nth-child(1) .employer_edit').text.should eq 'Dhruva Sagar'
  page.find('#employees-table tr:nth-child(1) td:nth-child(4)').text.should eq '9999999998'
end

#Issue.609

Then(/^Mail should be sent to the new employee$/) do
  ActionMailer::Base.deliveries.first.to.first.should eq 'dhruva12@tarkalabs.com'
  ActionMailer::Base.deliveries.first.subject.should eq ' Welcome to Moove'
end

# Issue.529
When(/^I open schedule of recent employee$/) do
  page.find('#employees-table tr:nth-child(1) .setup_schedule').click
  sleep(1)
end

Then(/^I should see Shift timings of excel$/) do
  selected = page.find('.employee-schedule-table .green-background')
  selected.find('.check_in').click
  selected.find('.employee_check_out_shift_id .check_out_shift_select').all(:option)[1].text.should eq '18:00'
  selected.find('.employee_check_in_shift_id .check_in_shift_select').all(:option)[1].text.should eq '9:00'
end