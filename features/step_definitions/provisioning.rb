require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given(/^Go to Provisioning page$/) do
  step 'Filling database'
  step 'I am on "/"'
  step 'I am try to log in as employer'
  step 'I am on "/provisioning"'
end

Given(/^I fill schedule fields for each day$/) do
  check_in_time = (Time.now + 10.minutes).strftime("%H:%M")
  check_out_time = (Time.now + 1.hours).strftime("%H:%M")
  sleep(2)
  @schedule = {
      'check_in_time' => check_in_time,
      'check_out_time' => check_out_time
  }

  today_of_weak_number = Time.now.wday+1
  (today_of_weak_number..7).each do |i|
    page.find('.employee-schedule-table tr:nth-child(2) td:nth-child(' + i.to_s + ') .schedule-content').click
    sleep(4)
    page.find('#employee_check_in_attributes_' + (i-1).to_s + '__check_in')
        .set(check_in_time)
    page.find('#employee_check_out_attributes_' + (i-1).to_s + '__check_out')
        .set(check_out_time)
    page.find('#employee_check_out_attributes_' + (i-1).to_s + '__site_id').find("option[value='1']").click
  end
end

Then(/^I should see filled schedule$/) do
  (1..7).each do |i|
    page.find('#employee_employee_schedules_attributes_' + i.to_s + '__check_in')
        .value.to_s.should eq @schedule['check_in_time'].to_s
    page.find('#employee_employee_schedules_attributes_' + i.to_s + '__check_out')
        .value.to_s.should eq @schedule['check_out_time'].to_s
  end
end

Then(/^I should see new employee$/) do
  page.find('#employees-table tr:nth-child(2) .employer_edit').text.should eq @new_employee['first_name'] + ' ' + @new_employee['last_name']
  # page.find('#employees-table tr:nth-child(2) td:nth-child(3)').text.should eq @new_employee['user_email']
  page.find('#employees-table tr:nth-child(2) td:nth-child(4)').text.should eq @new_employee['phone']
end

When(/^I click link "Delete" created employee$/) do
  page.find('#employees-table tr:nth-child(2) td:nth-child(10) .editor_remove').click
  sleep(2)
end

Then(/^I should not see deleted employee$/) do
  expect(page).not_to have_content(@new_employee['user_email'])
end

# Shifted to features/step_defnitions/employer/employer_provisioing.rb
# When(/^Fill new zone form$/) do
#   @zone_name = Faker::Number.between(2, 9)
#   page.find('#zone_name').set(@zone_name)
#   sleep(2)
# end

# Given(/^Fill incorrect new zone form$/) do
#   @zone_name = Faker::Lorem.word
#   page.find('#zone_name').set(@zone_name)
#   sleep(2)
# end

# Then(/^I should see new zone$/) do
#   sleep(2)
#   page.all('#zones-table tr').count.should eq 3
#   page.find('#zones-table tr:nth-child(2) .edit').text.should eq @zone_name.to_s
# end

# When(/^I try delete new zone$/) do
#   sleep(2)
#   page.find('#zones-table tr:nth-child(2) .editor_remove').click
#   sleep(2)
# end

# Then(/^I should not see new zone$/) do
#   sleep(2)
#   page.all('#zones-table tr').count.should eq 2
# end

When(/^I click link "Delete" created customer$/) do
  page.find('#employee-companies-table tr:nth-child(1) td:nth-child(7) .editor_remove').click
  sleep(2)
end

Then(/^I should not see deleted customer$/) do
  expect(page).not_to have_content(@new_customer['title'])
end

Given(/^Fill form new employer data$/) do
  # get fake data for new employer
  @new_employer= {}
  @new_employer['first_name'] = Faker::Name.first_name
  @new_employer['last_name'] = Faker::Name.last_name
  @new_employer['user_email'] = Faker::Internet.email
  @new_employer['phone'] = Faker::Number.number(10)
  @new_employer['legal_name'] = Faker::Name.first_name
  @new_employer['pan'] = Faker::Number.number(10)
  @new_employer['tan'] = Faker::Number.number(10)
  @new_employer['service_tax'] = Faker::Number.number(15)
  @new_employer['address'] = 'Amar Flats, Yesvantpur Industrial Suburb, Yeshwanthpur, Bengaluru, Karnataka 560086'

  page.find('#user_f_name').set(@new_employer['first_name'])
  page.find('#user_l_name').set(@new_employer['last_name'])
  page.find('#user_email').set(@new_employer['user_email'])
  page.find('#user_phone').set(@new_employer['phone'])
  page.find('#user_entity_attributes_legal_name').set(@new_employer['legal_name'])
  page.find('#user_entity_attributes_pan').set(@new_employer['pan'])
  page.find('#user_entity_attributes_tan').set(@new_employer['tan'])
  page.find('#user_entity_attributes_service_tax_no').set(@new_employer['service_tax'])
  page.find('#user_entity_attributes_hq_address').set(@new_employer['address'])

  # select company
  page.find('#user_entity_attributes_employee_company_idSelectBoxItText').click
  sleep(1)
  page.find('#user_entity_attributes_employee_company_idSelectBoxItOptions .selectboxit-option-anchor').click
end

When(/^I submit new employer form$/) do
  sleep(2)
  page.find('#new_user').find('.btn-primary').click
end

Then(/^I should see new employer$/) do
  page.find('#employers-table tr:nth-child(1) .employer_edit').text.should eq @new_employer['first_name'] + ' ' + @new_employer['last_name']
  page.find('#employers-table tr:nth-child(1) td:nth-child(4)').text.should eq @new_employer['user_email']
  page.find('#employers-table tr:nth-child(1) td:nth-child(5)').text.should eq @new_employer['phone']
end

When(/^I click link "Delete" created employer$/) do
  page.find('#employers-table tr:nth-child(1) td:nth-child(6) .editor_remove').click
  sleep(2)
end

Then(/^I should not see deleted employer$/) do
  expect(page).not_to have_content(@new_employer['user_email'])
end

When(/^I click link "Delete" created vehicle$/) do
  page.find('#vehicles-table tr:nth-child(1) td:nth-child(8) .editor_remove').click
  sleep(2)
end

Then(/^I should not see deleted vehicle$/) do
  expect(page).not_to have_content(@new_vehicle['plate'])
end


When(/^I closed employer form$/) do
  page.find('#form-employees').find('.cancel').click
  sleep(2)
end


When(/^I click link created vehicle$/) do |arg|
  page.find('#vehicles-table tr:nth-child(1) td:nth-child(8)) .vehicle_broke_down').click
  sleep(2)
end