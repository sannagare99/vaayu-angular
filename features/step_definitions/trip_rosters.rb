require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given(/^Create Trip roaster$/) do
  step 'Employee create trip request "check_in"'
  step 'Driver check in request'
  step 'I click link "Trips"'
  step 'I click link "Queue"'
  sleep(2)
  # step 'I select first trip in ad hocks trip tab'
  # step 'Buttons "Approve" pressed'
  # step 'I click link "Employee Trip Requests"'
  step 'I click to "#trip-date"'
  step 'I set on ".calendar.right .hourselect" value "11"'
  step 'I set on ".calendar.right .minuteselect" value "30"'
  step 'I set on ".calendar.right .ampmselect" value "PM"'
  step 'I set on ".calendar.left .hourselect" value "12"'
  step 'I set on ".calendar.left .ampmselect" value "AM"'
  step 'Buttons "Apply" pressed'
  step 'I click link "Approve"'
  step 'Buttons "Create Trip Roster" pressed'
  step 'Buttons "Submit" pressed'
end

Then(/^I open new trip roster manifest$/) do
  # page.find('#badge-trip-rosters').click
  # sleep(2)
  page.find('#trip-1 .btn-trip-info').click
end

Given(/^Assign driver to trip roster$/) do
  step 'I am logout'
  step 'I am try to log in as operator'
  step 'I am on "/trips"'
  sleep(2)

  # page.find('.trips-tabs #operator-assigned-trips').click
  # sleep(2)
  step 'I click link "Manifest"'
  page.find('#trip-1 #assign_driver').click
  sleep(2)
  #binding.pry
  # step 'Buttons "Assign Driver" pressed'
  # sleep(5)
  page.find('#assign-driver-table tbody tr:nth-child(1) td:nth-child(5) .nice-radio').click
  sleep(2)
  step 'I click link "Dispatch"'
  sleep(4)
  step 'I click link "Submit"'
  # step 'I am logout'
  # step 'I am try to log in as employer'
  # step 'I am on "/trips"'
end

Then(/^I should see right information in manifest modal$/) do
  sleep(2)
  #page.all('.card').count.should eq 3
  #page.find('.modal-content #trip-info-content-table span:nth-child(1)').text.should eq @user_employee.f_name + ' ' + @user_employee.l_name
  pick_up_time_text = page.find('.employee-trip-info-table td:nth-child(2) ').text
  pick_up_time = DateTime.parse(Time.now.strftime("%d/%m/%Y") + ' ' + pick_up_time_text)
  #eta_time_text = page.find('.modal-body div:nth-child(1) .card-footer-row:nth-child(2) .cf-label-value').text
  #eta_time = DateTime.parse(Time.now.strftime("%d/%m/%Y") + ' ' + eta_time_text)
  #duration = page.find('.modal-body .row>div:nth-child(2) .card-footer-row:nth-child(1) span:nth-child(2)').text
  #(pick_up_time + duration.to_i.minutes).should <= eta_time
end

Then(/^I select Wrong Assignment Exception$/) do
  page.find('#complete-with-exception-reasons-div').find('div:nth-child(1)').find('label').click
end

# Then(/^I select Operator Didnt Assign Exception$/) do
#   page.find('#complete-with-exception-reasons-div').find('div:nth-child(2)').find('label').click
# end

Then(/^I select Network Issue Exception$/) do
  page.find('#complete-with-exception-reasons-div').find('div:nth-child(3)').find('label').click
end

Then(/^I select App Issue Exception$/) do
  page.find('#complete-with-exception-reasons-div').find('div:nth-child(4)').find('label').click
end

Then(/^I select Driver Didnt Accept Exception$/) do
  page.find('#complete-with-exception-reasons-div').find('div:nth-child(5)').find('label').click
end

Then(/^I select Driver Off Duty Exception$/) do
  page.find('#complete-with-exception-reasons-div').find('div:nth-child(6)').find('label').click
end

Then(/^I select Trip was cancelled Exception$/) do
  page.find('#complete-with-exception-reasons-div').find('div:nth-child(7)').find('label').click
end

Then(/^I select Driver Completed Trip Exception$/) do
  page.find('#complete-with-exception-reasons-div').find('div:nth-child(8)').find('label').click
end

Then(/^I select other Exception$/) do
  @new_reason= {}
  @new_reason['reason'] = Faker::Name.first_name
  page.find('#complete-with-exception-reasons-div').find('div:nth-child(9)').find('label').click
  page.find('#complete_with_exception_text').set(@new_reason['reason'])
end

Then(/^I assign driver$/) do
  page.find('#assign-driver-table tbody td:nth-child(5) .nice-radio').click
  sleep(2)
  step 'I click link "Dispatch"'
  sleep(4)
  step 'I click link "Submit"'
  step 'I am logout'
  step 'I am try to log in as employer'
  step 'I am on "/trips"'
end

Given(/^Filling database with two drivers$/) do
  step 'I create companies in database'
  step 'I create site in database'
  step 'I create employer in database'
  step 'I create employee in database'
  step 'I create driver in database'
  step 'I create driver in database'
  step 'I create operator in database'
end

Then(/^I select new driver$/) do
  page.find('#assign-driver-table tbody tr:nth-child(2) td:nth-child(5) .nice-radio').click
end