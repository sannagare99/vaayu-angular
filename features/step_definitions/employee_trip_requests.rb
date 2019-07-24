require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
# Moved to features/step_definitions/employer/trip_requests.rb
# Given(/^Create Employee Trip Request "([^"]*)"$/) do |trip_type|
#   step 'Employee create trip request "' + trip_type + '"'
#   # step 'I click link "Trips"'
#   # step 'I click link "Ad Hoc Trips"'
#   # step 'I select first trip in ad hocks trip tab'
#   # step 'Buttons "Approve" pressed'
# end

# Given(/^Select Employee Trip Request "([^"]*)"$/) do |trip_type|
#   step 'I click link "Trips"'
#   step 'I click link "Queue"'
#   sleep(2)
#   step 'I click to "#trip-date"'
#   step 'I set on ".calendar.right .hourselect" value "11"'
#   step 'I set on ".calendar.right .minuteselect" value "30"'
#   step 'I set on ".calendar.right .ampmselect" value "PM"'
#   step 'I set on ".calendar.left .hourselect" value "12"'
#   step 'I set on ".calendar.left .ampmselect" value "AM"'
#   step 'Buttons "Apply" pressed'
#   step 'Change direction to "' + trip_type + '"'
# end

# Given(/^Change direction to "([^"]*)"$/) do |direction|
#   page.find('#trip-directionSelectBoxItText').click
#   sleep(2)
#   val = direction == 'check_in' ? '0' : '1'
#   page.find('#trip-directionSelectBoxItOptions').find('li[data-val="' + val + '"]').click
# end

# Then(/^I should see Employee Trip Requests$/) do
#   find('#employee-trip-request-table td:nth-child(3)').text.should eq @user_employee.f_name + ' ' + @user_employee.l_name
#   formated_time = @next_trip_time.strftime("%H:%M %m/%d/%Y")
#   find('#employee-trip-request-table td:nth-child(1)').text.should eq formated_time
#   #find('#employee-trip-request-table td:nth-child(6)').text.should eq @user_employee.phone
#   #find('#employee-trip-request-table td:nth-child(7)').text.to_i.should eq @user_employee.entity_id
# end

# When(/^Set employee schedule$/) do
#   sleep(2)
#   step 'I am on "/provisioning"'
#   step 'Go to Provisioning page ".employees" tab'
#   step 'I click link "Setup Schedule"'
#   step 'I fill schedule fields for each day'
#   step 'Buttons "Save changes" pressed'
#   sleep(2)
# end

# Then(/^Search for auto created check in trip request$/) do
#   sleep(2)
#   step 'Change direction to "check_in"'
#   @next_trip_time = @schedule['check_in_time'].to_time
# end

# Then(/^Search for auto created check out trip request$/) do
#   sleep(2)
#   step 'Change direction to "check_out"'
#   @next_trip_time = @schedule['check_out_time'].to_time
# end