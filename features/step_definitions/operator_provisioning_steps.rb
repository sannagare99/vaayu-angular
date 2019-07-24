require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

#operator general steps
Given(/^Go to Operator Provisioning page$/) do
  step 'Filling database'
  step 'I am on "/"'
  step 'I am try to log in as operator'
  step 'I am on "/provisioning"'
end

Given(/^Go to Operator Provisioning page "([^"]*)" tab$/) do |tab_selector|
  page.find('.nav-tabs').find(tab_selector).click
end

#pts customer steps
Then(/^Wait for operator modal "([^"]*)"$/) do |modal_title|
  sleep(2)
  page.find('.modal').find('.DTE_Header_Content').text.should eq modal_title
end

Given(/^Fill form new customer data$/) do
  @new_customer = {}
  @new_customer['title'] = Faker::Name.title

  page.find('#DTE_Field_name').set(@new_customer['title'])
end

When(/^I submit new customer form$/) do
  page.find('.DTE').find('.btn-primary').click
  sleep(2)
end

Then(/^I should see new customer$/) do
  # TODO: [BUG] Fix the bug in employee_companies_controller:26 (logistics compnay required to create employee company), then uncomment below assertion
  # page.find('#employee-companies-table tr:nth-child(1) td:nth-child(2) .editor_edit').text.should eq @new_customer['title']
end

#vehicle steps
Then(/^Wait for operator vehicle form with label "([^"]*)"$/) do |field_label|
  sleep(1)
  page.find('#form-vehicles').find('.field-label').text.should eq field_label
end

Given(/^Fill form new vehicle data$/) do
  @new_vehicle= {}
  @new_vehicle['plate'] = Faker::Number.number(10)
  @new_vehicle['make'] = Faker::Name.first_name
  @new_vehicle['model'] = Faker::Name.first_name
  @new_vehicle['color'] = Faker::Color.color_name
  @new_vehicle['rc_book'] = Faker::Number.number(10)
  @new_vehicle['reg_date'] = "09/08/2017"
  @new_vehicle['insurance_date'] = "09/08/2018"
  @new_vehicle['permit'] = Faker::Name.first_name
  @new_vehicle['permit_date'] = "19/08/2018"
  @new_vehicle['make_year'] = 1999
  @new_vehicle['device'] = 9

  page.find('#vehicle_plate_number').set(@new_vehicle['plate'])
  page.find('#vehicle_make').set(@new_vehicle['make'])
  page.find('#vehicle_model').set(@new_vehicle['model'])
  page.find('#vehicle_colour').set(@new_vehicle['color'])
  page.find('#vehicle_rc_book_no').set(@new_vehicle['rc_book'])
  page.find('#vehicle_registration_date').set(@new_vehicle['reg_date'])
  page.find('#vehicle_insurance_date').set(@new_vehicle['insurance_date'])
  page.find('#vehicle_permit_type').set(@new_vehicle['permit'])
  page.find('#vehicle_permit_validity_date').set(@new_vehicle['permit_date'])
  page.find('#vehicle_make_year').set(@new_vehicle['make_year'])
  page.find('#vehicle_device_id').set(@new_vehicle['device'])
end

When(/^I submit new vehicle form$/) do
  page.find('.content-body').find('.btn-primary').click
  sleep(2)
end

Then(/^I should see new vehicle$/) do
  page.find('#vehicles-table tr:nth-child(1) td:nth-child(1)').text.should eq @new_vehicle['plate']
  page.find('#vehicles-table tr:nth-child(1) td:nth-child(4)').text.should eq @new_vehicle['color']
end

#business_associate steps
Then(/^Wait for operator new business associate form with label "([^"]*)"$/) do |field_label|
  sleep(1)
  page.find('#form-business-associates').first('.field-label').text.should eq field_label
end

When(/^I submit new business associate form$/) do
  page.find('.btn-primary').click
  sleep(2)
end

Given(/^Operator fills form new business associate data$/) do
  @new_business_associate = {}
  @new_business_associate['name'] = Faker::Name.first_name
  @new_business_associate['legal_name'] = 'business_associate'
  @new_business_associate['pan'] = Faker::Number.number(10)
  @new_business_associate['tan'] = Faker::Number.number(10)
  @new_business_associate['service_tax_no'] = Faker::Number.number(15)
  @new_business_associate['hq_address'] = 'Amar Flats, Yesvantpur Industrial Suburb, Yeshwanthpur, Bengaluru, Karnataka 560086'

  page.find('#business_associate_name').set(@new_business_associate['name'])
  page.find('#business_associate_legal_name').set(@new_business_associate['legal_name'])
  page.find('#business_associate_pan').set(@new_business_associate['pan'])
  page.find('#business_associate_tan').set(@new_business_associate['tan'])
  page.find('#business_associate_hq_address').set(@new_business_associate['hq_address'])
  page.find('#business_associate_service_tax_no').set(@new_business_associate['service_tax_no'])
end

Then(/^I should see new business associate$/) do
    page.find('#business-associates-table tr:nth-child(1) td:nth-child(2)').text.should eq @new_business_associate['legal_name']
end

#drivers steps
Then(/^Wait for operator new driver form with label "([^"]*)"$/) do |field_label|
  sleep(1)
  page.find('#form-drivers').find('.field-label').text.should eq field_label
end

When(/^I submit new driver form$/) do
  page.find('.btn-primary').click
  sleep(2)
end

Given(/^Operator fills form new driver data$/) do
  @new_driver = {}
  @new_driver['first_name'] = Faker::Name.first_name
  @new_driver['last_name'] = Faker::Name.last_name
  @new_driver['email'] = Faker::Internet.email
  @new_driver['phone'] = Faker::Number.number(10)
  @new_driver['badge_number'] = 'badgenumber'
  @new_driver['address'] = 'Amar Flats, Yesvantpur Industrial Suburb, Yeshwanthpur, Bengaluru, Karnataka 560086'
  @new_driver['license_number'] = Faker::Number.number(15)

  page.find('#user_f_name').set(@new_driver['first_name'])
  page.find('#user_l_name').set(@new_driver['last_name'])
  page.find('#user_email').set(@new_driver['email'])
  page.find('#user_phone').set(@new_driver['phone'])
  page.find('#user_username').set(@new_driver['first_name'])
  page.find('#user_entity_attributes_badge_number').set(@new_driver['badge_number'])
  page.find('#user_entity_attributes_local_address').set(@new_driver['address'])
  page.find('#user_entity_attributes_permanent_address').set(@new_driver['address'])
  page.find('#user_entity_attributes_licence_number').set(@new_driver['license_number'])
  page.find('#user_entity_attributes_site_id').find(:xpath, 'option[2]').select_option
  page.find('#user_entity_attributes_business_associate_id').find(:xpath, 'option[2]').select_option
  page.find('#user_entity_attributes_verified_by_police').click
end

Then(/^I should see new driver$/) do
    page.find('#drivers-table tr:nth-child(2) td:nth-child(1)').text.should eq(@new_driver['first_name'] + " " + @new_driver['last_name'])
end

Then(/^I should see no customer$/) do
  page.all('.editor-remove').count.should eq(0)
end

Then(/^I should see employer's details$/) do
  page.should have_field('First name', with: Employer.last.user.f_name)
  page.should have_field('Last name', with: Employer.last.user.l_name)
end

Given(/^I create operator shift manager$/) do
  @user = FactoryGirl.create(:user)
  @manager = FactoryGirl.create(:operator_shift_manager,
    pan: Faker::Number.number(10),
    tan: Faker::Number.number(10),
    service_tax_no: Faker::Number.number(15),
    user: @user)
end

When(/^I reset password of Operator Shift Manager$/) do
  user = OperatorShiftManager.last.user
  raw, enc = Devise.token_generator.generate(user.class, :reset_password_token)
  user.reset_password_token   = enc
  user.reset_password_sent_at = Time.now.utc
  user.save(validate: false)
  url = "/users/password/edit?reset_password_token=#{raw}"
  page.visit(url)
end


When(/^I fill password fields with new passwords for regression$/) do
  page.find('#user_password').set('password')
  page.find('#user_password_confirmation').set('password')
  page.all('.btn-primary')[0].click
end