require File.expand_path(File.join(File.dirname(__FILE__), "../../", "support", "paths"))

def attr_index attr
  case attr
  when 'Process Code'
    2
  when 'Sex'
    3
  when 'ETA'
    5
  when 'Shift Starts'
    6
  else
    2
  end
end

def board_attr_index attr
  case attr
  when 'Process Code'
    2
  when 'Sex'
    3
  when 'ETA'
    4
  when 'Start Shift'
    5
  else
    2
  end
end

def check_process_code employee,field
  true
end

def check_sex employee_trip,field
  employee_trip.employee.gender.to_s[0].upcase == field
end

def check_eta employee_trip,field
  puts field
  puts employee_trip.trip.planned_date.localtime.strftime("%I:%M%p")
  field == employee_trip.trip.planned_date.localtime.strftime("%I:%M%p")
end

def check_shift_start employee_trip,field
  puts field
  puts employee_trip.date.localtime.strftime("%I:%M")
  field == employee_trip.date.localtime.strftime("%I:%M")
end

def check_start_shift employee_trip,field
  puts field
  puts employee_trip.date.localtime.strftime("%I:%M%p")
  field == employee_trip.date.localtime.strftime("%I:%M%p")
end

def check_manifest_attr attr,employee,field,trip_type
  emp_trip = EmployeeTrip.where(employee: employee, trip_type: trip_type).first
  # puts emp_trip
  case attr
  when 'Process Code'
    check_process_code(employee,field)
  when 'Sex'
    check_sex(emp_trip,field)
  when 'ETA'
    check_eta(emp_trip,field)
  when 'Shift Starts'
    check_shift_start(emp_trip,field)
  when 'Start Shift'
    check_start_shift(emp_trip,field)
  else
    true
  end
end

def create_trip_roster(all_employee_trips)
  @trip = Trip.new(:employee_trip_ids_with_prefix=>["1"])
    @trip.site = @trip.employee_trips.first.employee.site
    @trip.bus_rider = @trip.employee_trips.first.bus_rider
    @trip.save!
end

When(/^I create trip roster of "([^"]*)" trip requests$/) do |index|
  create_trip_roster({"0":["1"]})
end

When(/^I click Manifest No. "([^"]*)"$/) do |index|
  page.find('#operator-assigned-trips-table tbody').all('tr')[index.to_i-1].find('td:nth-child(1) a').click
  # puts page.find('#operator-assigned-trips-table tbody').all('tr')[index.to_i-1].find('td:nth-child(1)')['innerHTML']
end

Then(/^I should check for "([^"]*)" for all employees in selected manifest for "([^"]*)"$/) do |attr,trip_type|
  step 'I should see "'+attr+'"'
  page.all('#operator-unassigned-roster-table tbody tr').each do |tr|
    name = tr.find('td:nth-child(1)').text
    emp = User.where(f_name: name.split(" ")[0]).first.entity
    field = tr.find('td:nth-child('+attr_index(attr).to_s+')').text
    check_manifest_attr(attr,emp,field,trip_type).should eq true
  end
end

Then(/^I should check for "([^"]*)" for all employees in selected manifest for "([^"]*)" in Trip Board$/) do |attr,trip_type|
  step 'I should see "'+attr+'"'
  page.all('#trip-info-content-table tbody tr').each do |tr|
    name = tr.find('td:nth-child(1)').text
    emp = User.where(f_name: name.split(" ")[0]).first.entity
    field = tr.find('td:nth-child('+board_attr_index(attr).to_s+')').text
    check_manifest_attr(attr,emp,field,trip_type).should eq true
  end
end

When(/^I select Employee Trip Requests cluster "([^"]*)"$/) do |count|
  page.all('#employee-trip-request-cluster-table tr')[count.to_i-1].find('td:nth-child(1)').click
end

When(/^I call employee "([^"]*)" on manifest$/) do |count|
  page.all('#operator-unassigned-roster-table tbody tr')[count.to_i-1].find('td:nth-child(1) a').click
end

When(/^I call driver "([^"]*)" on manifest$/) do |count|
  page.all('#operator-assigned-trips-table tbody tr')[count.to_i-1].find('td:nth-child(5) a').click
end

When(/^I open map of trip manifest$/) do
  page.all('.btn-trip-info')[0].click
  page.find('#open-map').click
end

When(/^I should see google map opened in trip manifest$/) do
  page.has_content?('Map data ©2018 Google').should be true
end

# Issue.635
Then(/^I assign guard to last manifest$/) do
  @guard = Employee.where(is_guard: 1).first
  Trip.last.add_guard_to_trip(@guard.id)
end

Given(/^Set Employee Trip Status of Guard as missed$/) do
  @guard = Employee.where(is_guard: 1).first
  @guard.employee_trips.last.update( status: :missed)
end
