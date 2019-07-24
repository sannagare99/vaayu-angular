require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given(/^I create data for operator report$/) do
	step 'Create operator for the operator report'
	step 'Create site for operator report'
	step 'Create employees for operator report'
	step 'Create vehicle for operator report'
	step 'Create driver for operator report'
	step 'Create daily employee trips for operator report'
	step 'Create daily trips for operator report'
	step 'Create daily driver shifts trips data for operator report'
	step 'Create daily trip route exceptions data for operator report'
	step 'Complete trips for operator report'
end

Given(/^Create operator for the operator report$/) do
	@operator = FactoryGirl.create(:operator, logistics_company: @logistics_company)
end

Given(/^Create site for operator report$/) do
	address = 'Shubham Complex, Opposite ESIS Hospital, Akurli Road, Akurli Industry Estate, Kandivali East, Mumbai, Maharashtra 400101, India'
	@site = FactoryGirl.create(:site, employee_company: @employee_company, address: address, latitude: 19.2013359, longitude: 72.855722)
end


Given(/^Create employees for operator report$/) do
	address_1 = '2nd Floor, Kenilworth Mall, Phase 2, Off Linking Road, Behind KFC, Bandra West, Bandra West, Mumbai, Maharashtra 400050, India'
	id_1 = 'ID233E3'
	@employee_1 = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company, employee_id: id_1, home_address: address_1)
end

Given(/^Create vehicle for operator report$/) do
	device_id_1 = 'd001'
	plate_number_1 = 'MH12301'
	@vehicle_1 = FactoryGirl.create(:vehicle, plate_number: plate_number_1, device_id: device_id_1)
end

Given(/^Create driver for operator report$/) do
	address_1 = 'Shop No. 4, Mishra House, Khar West, Chitrakar Dhurandhar Road, Ram Krishna Nagar, Ram Krishna Nagar, Khar West, Mumbai, Maharashtra 400052, India'
	badge_number_1 = 'ABC'
	aadhaar_number_1 = '123'
	licence_number_1 = 'ABCDEFGHIJ12345'
	@driver_1 = FactoryGirl.create(:driver, site: @site, logistics_company: @logistics_company, permanent_address: address_1, local_address: address_1, badge_number: badge_number_1, aadhaar_number: aadhaar_number_1, licence_number: licence_number_1, vehicle: @vehicle_1)
	@auth_token_driver = @driver_1.user.create_new_auth_token
end

Given(/^Create daily employee trips for operator report$/) do
	@trip_time_0 = Time.now - 25.hour
	@trip_time_1 = Time.now - 1.hour
	@employee_trip_0 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_1.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_0, bus_rider: false, date: @trip_time_0, rating: 4)
	@employee_trip_1 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_1.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_1, bus_rider: false, date: @trip_time_1, rating: 4)
end

Given(/^Create daily trips for operator report$/) do
	@trip_0 = Trip.create(site_id: @site.id, trip_type: 0, status: 'active', employee_trip_ids: [@employee_trip_0.id], driver: @driver_1, vehicle: @vehicle_1, start_date: @trip_time_0 - 15.minutes)
	@employee_trip_0.update(trip_id: @trip_0.id, trip_route_id: @trip_0.trip_routes.first.id)
	@trip_1 = Trip.create(site_id: @site.id, trip_type: 0, status: 'active', employee_trip_ids: [@employee_trip_1.id], driver: @driver_1, vehicle: @vehicle_1, start_date: @trip_time_1 - 15.minutes)
	@employee_trip_1.update(trip_id: @trip_1.id, trip_route_id: @trip_1.trip_routes.first.id)
end

Given(/^Create daily driver shifts trips data for operator report$/) do
	DriversShift.create(driver_id: @driver_1.id, vehicle_id: @vehicle_1.id, start_time: 3.days.ago, end_time: 3.hours.from_now)
end

Given(/^Create daily trip route exceptions data for operator report$/) do
	TripRouteException.create(trip_route_id: @trip_1.trip_routes.first.id, date: @trip_time_1, exception_type: :employee_no_show, status: :closed, resolved_date: @trip_time_1 - 5.minutes)
end

Given(/^Complete trips for operator report$/) do
	@employee_trip_0.update(status: :completed)
	@trip_0.update(status: :completed, completed_date: @trip_time_0 - 1.minutes, real_duration: 1.minutes)
	@employee_trip_1.update(status: :completed)
	@trip_1.update(status: :completed, completed_date: @trip_time_1 - 1.minutes, real_duration: 1.minutes)
end


Then(/^I can see standard operator reports trip logs$/) do
	page.execute_script("$('a[href=#trip-logs]').click()")
	sleep(1)
	step 'I can see trip logs in operator reports'
end

Then(/^I can see standard operator reports employee logs$/) do
	page.execute_script("$('a[href=#employee-logs]').click()")
	sleep(1)
	step 'I can see employee log in operator reports'
end

Then(/^I can see standard operator reports vehicle deployment$/) do
	page.execute_script("$('a[href=#vehicle-deployment]').click()")
	sleep(1)
	step 'I can see vehicle deployment in operator reports'
end

Then(/^I can see standard operator reports ota$/) do
	page.execute_script("$('a[href=#ota]').click()")
	sleep(1)
	step 'I can see ota in operator reports'
end

Then(/^I can see standard operator reports otd$/) do
	page.execute_script("$('a[href=#otd]').click()")
	sleep(1)
	step 'I can see otd in operator reports'
end

Then(/^I can see standard operator reports vehicle utilisation$/) do
	page.execute_script("$('a[href=#vehicle-utilisation]').click()")
	sleep(1)
	step 'I can see vehicle utilisation in operator reports'
end

Then(/^I can see standard operator reports employee no show$/) do
	page.execute_script("$('a[href=#employee-no-show]').click()")
	sleep(1)
	step 'I can see employee no show in operator reports'
end

Then(/^I can see standard operator reports employee satisfaction$/) do
	page.execute_script("$('a[href=#employee-satisfaction]').click()")
	sleep(1)
	step 'I can see employee satisfaction in operator reports'
end

Then(/^I can see standard operator reports operations summary$/) do
	page.execute_script("$('a[href=#operations-summary]').click()")
	sleep(1)
	step 'I can see operations summary in operator reports'
end

Then(/^I can see standard operator reports trip exceptions$/) do
	page.execute_script("$('a[href=#trip-exceptions]').click()")
	sleep(1)
	step 'I can see trip exceptions in operator reports'
end

Then(/^I can see standard operator reports on time arrivals$/) do
	page.execute_script("$('a[href=#on-time-arrivals]').click()")
	sleep(1)
	step 'I can see on time arrivals in operator reports'
end

Then(/^I can see standard operator reports on time departures$/) do
	page.execute_script("$('a[href=#on-time-departures]').click()")
	sleep(1)
	step 'I can see on time departures in operator reports'
end

Then(/^I can see standard operator reports no show and cancellations$/) do
	page.execute_script("$('a[href=#no-show-and-cancellations]').click()")
	sleep(1)
	step 'I can see no show and cancellations in operator reports'
end

Then(/^I can see standard operator reports panic alarms$/) do
	page.execute_script("$('a[href=#panic-alarms]').click()")
	sleep(1)
	step 'I can see panic alarms in operator reports'
end

Given(/^I set calendar dates for operator reports$/) do
  page.execute_script("$('.calendar.left .input-mini.form-control.active').val(\"#{1.month.ago.strftime('%d/%m/%Y %l:%M %p')}\").change()")
  sleep(1)
  page.execute_script("$('.calendar.right .input-mini.form-control').val(\"#{1.month.from_now.strftime('%d/%m/%Y %l:%M %p')}\").change()")
  sleep(1)
  page.find('button.applyBtn.btn.btn-sm.btn-primary').click
  sleep(2)
end

Then(/^I can see trip logs in operator reports$/) do
  page.find('#trip-logs-picker').click
  step 'I set calendar dates for operator reports'
  page.find('#reports-trip-logs-table th:nth-child(2)').text.should eq("Trip Id")
  page.find('#reports-trip-logs-table tr:nth-child(1) td:nth-child(2)').text.should eq("2")
  page.find('#reports-trip-logs-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
  page.find('#reports-trip-logs-table th:nth-child(2)').click
  sleep(2)
  page.find('#reports-trip-logs-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-trip-logs-table tr:nth-child(2) td:nth-child(2)').text.should eq("2")
end

Then(/^I can see employee log in operator reports$/) do
  page.find('#employee-logs-picker').click
  step 'I set calendar dates for operator reports'
  page.find('#reports-employee-logs-table th:nth-child(2)').text.should eq("Trip Id")
  page.find('#reports-employee-logs-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-employee-logs-table tr:nth-child(2) td:nth-child(2)').text.should eq("2")
  page.find('#reports-employee-logs-table th:nth-child(2)').click
  sleep(1)
  page.find('#reports-employee-logs-table th:nth-child(2)').click
  sleep(2)
  page.find('#reports-employee-logs-table tr:nth-child(1) td:nth-child(2)').text.should eq("2")
  page.find('#reports-employee-logs-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
end

Then(/^I can see vehicle deployment in operator reports$/) do
  page.find('#vehicle-deployment-picker').click
  step 'I set calendar dates for operator reports'
end

Then(/^I can see ota in operator reports$/) do
  page.find('#ota-picker').click
  step 'I set calendar dates for operator reports'
end

Then(/^I can see otd in operator reports$/) do
  page.find('#otd-picker').click
  step 'I set calendar dates for operator reports'
end

Then(/^I can see vehicle utilisation in operator reports$/) do
  page.find('#vehicle-utilisation-picker').click
  step 'I set calendar dates for operator reports'
end

Then(/^I can see employee no show in operator reports$/) do
  page.find('#employee-no-show-picker').click
  step 'I set calendar dates for operator reports'
end

Then(/^I can see employee satisfaction in operator reports$/) do
  page.find('#employee-satisfaction-picker').click
  step 'I set calendar dates for operator reports'
  page.find('#reports-employee-satisfaction-table th:nth-child(6)').text.should eq("Trip ID")
  page.find('#reports-employee-satisfaction-table tr:nth-child(1) td:nth-child(6)').text.should eq("1")
  page.find('#reports-employee-satisfaction-table tr:nth-child(2) td:nth-child(6)').text.should eq("2")
  page.find('#reports-employee-satisfaction-table th:nth-child(6)').click
  sleep(1)
  page.find('#reports-employee-satisfaction-table th:nth-child(6)').click
  sleep(2)
  page.find('#reports-employee-satisfaction-table tr:nth-child(1) td:nth-child(6)').text.should eq("2")
  page.find('#reports-employee-satisfaction-table tr:nth-child(2) td:nth-child(6)').text.should eq("1")
end

Then(/^I can see operations summary in operator reports$/) do
  page.find('#operations-summary-picker').click
  step 'I set calendar dates for operator reports'
  page.find('#reports-operations-summary-table th:nth-child(2)').text.should eq("Total Trips")
  page.find('#reports-operations-summary-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-operations-summary-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
end

Then(/^I can see trip exceptions in operator reports$/) do
  page.find('#trip-exceptions-picker').click
  step 'I set calendar dates for operator reports'
  page.find('#reports-trip-exceptions-table th:nth-child(2)').text.should eq("Total Trips")
  page.find('#reports-trip-exceptions-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-trip-exceptions-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
end

Then(/^I can see on time arrivals in operator reports$/) do
  page.find('#on-time-arrivals-picker').click
  step 'I set calendar dates for operator reports'
  page.find('#reports-on-time-arrivals-table th:nth-child(2)').text.should eq("Total Logins")
  page.find('#reports-on-time-arrivals-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-on-time-arrivals-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
end

Then(/^I can see on time departures in operator reports$/) do
  page.find('#on-time-departures-picker').click
  step 'I set calendar dates for operator reports'
end

Then(/^I can see no show and cancellations in operator reports$/) do
  page.find('#no-show-and-cancellations-picker').click
  step 'I set calendar dates for operator reports'
  page.find('#reports-no-show-and-cancellations-table th:nth-child(2)').text.should eq("Total Employees")
  page.find('#reports-no-show-and-cancellations-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-no-show-and-cancellations-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
end

Then(/^I can see panic alarms in operator reports$/) do
  page.find('#panic-alarms-picker').click
  step 'I set calendar dates for operator reports'
end