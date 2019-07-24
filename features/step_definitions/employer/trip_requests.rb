require File.expand_path(File.join(File.dirname(__FILE__), "../../", "support", "paths"))
require 'sidekiq/testing'

Given(/^Create Employee Trip Request "([^"]*)"$/) do |trip_type|
  step 'Employee create trip request "' + trip_type + '"'
  # step 'I click link "Trips"'
  # step 'I click link "Ad Hoc Trips"'
  # step 'I select first trip in ad hocks trip tab'
  # step 'Buttons "Approve" pressed'
end

Given(/^Select Employee Trip Request "([^"]*)" for "([^"]*)"$/) do |trip_type,date|
  step 'I click link "Trips"'
  step 'I click link "Queue"'
  sleep(2)
  step 'I click to "#trip-date"'
  step 'I click to ".calendar-table" calendar on "' + date.to_s + '" date'
  step 'I click to "#trip-time"'
  page.find(".calendar.right .input-mini").set("11:30 PM")
  # fill_in('.calendar.right .input-mini', with: "")
  step 'I fill ".calendar.left .input-mini" field with text "12:00 AM"'
  page.find(".calendar.left .input-mini").set("12:00 AM")
  # step 'I fill ".calendar.right .input-mini" field with text "11:30 PM"'
  # page.find(".calendar.right .input-mini").set("11:30 PM")
  step 'Buttons "Apply" pressed'
  step 'Change direction to "' + trip_type + '"'
  step 'Change direction to "' + trip_type + '"'
end

Given(/^Select Employee Trip Request "([^"]*)" for "([^"]*)" fast$/) do |trip_type,date|
  step 'I click link "Trips"'
  step 'I click link "Queue"'
  sleep(2)
  step 'I click to "#trip-date"'
  case date
  when 'Today'
    day = Date.today.strftime("%d/%m/%Y")
  when 'Tomorrow'
    day = Date.tomorrow.strftime("%d/%m/%Y")
  else
    day = Date.today.strftime("%d/%m/%Y")
  end
  # page.find("#trip-time").set(date)
  step 'I click to "#trip-time"'
  page.find("#trip-time").set("12:00 AM - 11:30 PM")
  step 'Buttons "Apply" pressed'
  step 'Change direction to "' + trip_type + '"'
  step 'Change direction to "' + trip_type + '"'
end

Given(/^Change direction to "([^"]*)"$/) do |direction|
  page.find('#trip-directionSelectBoxItText').click
  sleep(2)
  val = direction == 'check_in' ? '0' : '1'
  page.find('#trip-directionSelectBoxItOptions').find('li[data-val="' + val + '"]').click
end

Then(/^I should see "([^"]*)" Employee Trip Requests for "([^"]*)"$/) do |count,trip_type|
  if count == 'Multiple'
    page.all('#employee-trip-request-table tr').count.should > 0
  else
    count = count.to_i
    if count == 1
      find('#employee-trip-request-table td:nth-child(3)').text.include?(@user_employees[0].f_name + ' ' + @user_employees[0].l_name).should be true
      formated_time = @shift_data[trip_type].strftime("%H:%M %m/%d/%Y")
      find('#employee-trip-request-table td:nth-child(1)').text.should eq formated_time
      gender_display = (@employees[0].gender == 'male')? 'M':'F'
      find('#employee-trip-request-table td:nth-child(4)').text.should eq gender_display
    elsif count == 0
      page.all('#employee-trip-request-table tr').count.should eq 0
    else
      sleep(3)
      page.all('#employee-trip-request-table tr').count.should eq count.to_i+1
    end
  end
  #find('#employee-trip-request-table td:nth-child(7)').text.to_i.should eq @user_employee.entity_id
end

Then(/^I should see "([^"]*)" Employee Trip Requests for confirm$/) do |count|
  page.all('#trip-roster-confirm-table tr').count.should eq count.to_i+1
end

When(/^I add "([^"]*)" minutes to "([^"]*)" shift time of trip request$/) do |count,trip_type|
  @shift_data[trip_type] = @shift_data[trip_type]+2.minutes
  page.find('.DTE_Bubble_Liner #DTE_Field_datetime').set(@shift_data[trip_type].to_s[11..15])
end

Then(/^I find "([^"]*)" shift time of trip request "([^"]*)" updated$/) do |trip_type,index|
  page.all('tbody tr')[index.to_i-1].text[0..4].should eq @shift_data[trip_type].to_s[11..15]
end

When(/^I fill Trip Queue Search field with "([^"]*)" name of Employee "([^"]*)"$/) do |match,index|
  emp = Employee.find(index.to_i)
  case match
  when 'Partial'
    search = emp.user.f_name[0..2]
  when 'Complete'
    search = emp.user.f_name + ' ' + emp.user.l_name
  else
    search = emp.user.f_name + ' ' + emp.user.l_name
  end
  @search_emp = emp
  page.find('#queue-table_search_value').set(search)
end

Then(/^I should see "([^"]*)" employee trip request with name matched with Search Input$/) do |count|
  sleep(1)
  page.all('tbody tr').count.should eq count.to_i
  search = page.find('#queue-table_search_value').text
  sleep(1)
  page.all('tbody tr').each do |emp|
    expect(emp.find('td:nth-child(3)').text).to include(search) if (emp.find('td:nth-child(3)').text != 'Employee')
  end
end

When(/^I select all Employee Trip Requests$/) do
  page.find('#employee-trip-request-table thead .checkbox-select').click
end

When(/^I deselect all Employee Trip Requests$/) do
  page.find('#employee-trip-request-table thead .checkbox-select').click
  page.find('#employee-trip-request-table thead .checkbox-select').click
end

When(/^I select "([^"]*)" Employee Trip Requests for Trip manifest$/) do |count|
  count.to_i.times do |index|
    page.all('#employee-trip-request-table tbody tr').each do |tr|
      if !tr['class'].include? 'selected' 
        tr.find('.checkbox-select').click
        # puts tr['innerHTML']
        break
      end
    end
  end
end

When(/^I deselect "([^"]*)" Employee Trip Requests for Trip manifest$/) do |count|
  count.to_i.times do |index|
    page.all('#employee-trip-request-table tbody tr').each do |tr|
      if tr['class'].include? 'selected' 
        tr.find('.checkbox-select').click
        # puts tr['innerHTML']
        break
      end
    end
  end
end

Then(/^I should see "([^"]*)" Employee Trip Requests selected for Trip manifest$/) do |count|
  if count == "Multiple"
    page.all(:css, 'tr.selected').count > 1
    @auto_selected_count = page.all(:css, 'tr.selected').count
  end
end

Then(/^I should see Employee Trip Requests selected for Trip manifest incremented by "([^"]*)"$/) do |count|
  page.all(:css, 'tr.selected').count.should eq @auto_selected_count+count.to_i
end

Then(/^I should see "([^"]*)" Employee Trip Requests clusters$/) do |count|
  if count == "Multiple"
    page.all('#employee-trip-request-cluster-table tr').count > 1
    @cluster_count = page.all(:css, 'tr.selected').count
    sleep(2)
  elsif count == "More"
    page.all('#employee-trip-request-cluster-table tr').count > @cluster_count
    @cluster_count = page.all(:css, 'tr.selected').count
    sleep(2)
  end
end

# Issue.618

When(/^I open import manifest excel modal$/) do
  step 'I click link "Trips"'
  step 'I click link "Queue"'
  sleep(2)
  page.find('#ingest-manifest').click
end


When(/^I upload excel and start worker$/) do
  Sidekiq::Worker.clear_all
  attach_file('ingest_job[file]', Rails.root.join('features/excels/ingest_manifest.xlsx'))
  sleep(2)
  page.find('.modal-content .btn-primary').click
  sleep(2)
  sleep(3)
  Sidekiq::Worker.drain_all
  sleep(5)
end

Then(/^I see trip request generated for these employees$/) do
  page.find('#processed-count').text.should eq '2'
  page.find('#employees-provisioned-count').text.should eq '2'
  page.find('#schedules-assigned-count').text.should eq '2'
  page.find('.modal-content .btn-primary').click
end