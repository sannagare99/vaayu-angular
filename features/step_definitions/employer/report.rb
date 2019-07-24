require File.expand_path(File.join(File.dirname(__FILE__), "../..", "support", "paths"))

Given(/^I create data for employer report$/) do
  step 'Create operator for the employer report'
  step 'Create site for employer report'
  step 'Create employees for employer report'
  step 'Create vehicle for employer report'
  step 'Create driver for employer report'
  step 'Create daily employee trips for employer report'
  step 'Create daily trips for employer report'
  step 'Create daily driver shifts trips data for employer report'
  step 'Create daily trip route exceptions data for employer report'
  step 'Complete trips for employer report'
end

Given(/^Create operator for the employer report$/) do
  @operator = FactoryGirl.create(:operator, logistics_company: @logistics_company)
end

Given(/^Create site for employer report$/) do
  address = 'Shubham Complex, Opposite ESIS Hospital, Akurli Road, Akurli Industry Estate, Kandivali East, Mumbai, Maharashtra 400101, India'
  @site = FactoryGirl.create(:site, employee_company: @employee_company, address: address, latitude: 19.2013359, longitude: 72.855722)
end


Given(/^Create employees for employer report$/) do
  address_1 = '2nd Floor, Kenilworth Mall, Phase 2, Off Linking Road, Behind KFC, Bandra West, Bandra West, Mumbai, Maharashtra 400050, India'
  id_1 = 'ID233E3'
  @employee_1 = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company, employee_id: id_1, home_address: address_1)
end

Given(/^Create vehicle for employer report$/) do
  device_id_1 = 'd001'
  plate_number_1 = 'MH12301'
  @vehicle_1 = FactoryGirl.create(:vehicle, plate_number: plate_number_1, device_id: device_id_1)
end

Given(/^Create driver for employer report$/) do
  address_1 = 'Shop No. 4, Mishra House, Khar West, Chitrakar Dhurandhar Road, Ram Krishna Nagar, Ram Krishna Nagar, Khar West, Mumbai, Maharashtra 400052, India'
  badge_number_1 = 'ABC'
  aadhaar_number_1 = '123'
  licence_number_1 = 'ABCDEFGHIJ12345'
  @driver_1 = FactoryGirl.create(:driver, site: @site, logistics_company: @logistics_company, permanent_address: address_1, local_address: address_1, badge_number: badge_number_1, aadhaar_number: aadhaar_number_1, licence_number: licence_number_1, vehicle: @vehicle_1)
  @auth_token_driver = @driver_1.user.create_new_auth_token
end

Given(/^Create daily employee trips for employer report$/) do
  @trip_time_0 = Time.now - 25.hour
  @trip_time_1 = Time.now - 1.hour
  @employee_trip_0 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_1.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_0, bus_rider: false, date: @trip_time_0, rating: 4)
  @employee_trip_1 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_1.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_1, bus_rider: false, date: @trip_time_1, rating: 4)
end

Given(/^Create daily trips for employer report$/) do
  @trip_0 = Trip.create(site_id: @site.id, trip_type: 0, status: 'active', employee_trip_ids: [@employee_trip_0.id], driver: @driver_1, vehicle: @vehicle_1, start_date: @trip_time_0 - 15.minutes)
  @employee_trip_0.update(trip_id: @trip_0.id, trip_route_id: @trip_0.trip_routes.first.id)
  @trip_1 = Trip.create(site_id: @site.id, trip_type: 0, status: 'active', employee_trip_ids: [@employee_trip_1.id], driver: @driver_1, vehicle: @vehicle_1, start_date: @trip_time_1 - 15.minutes)
  @employee_trip_1.update(trip_id: @trip_1.id, trip_route_id: @trip_1.trip_routes.first.id)
end

Given(/^Create daily driver shifts trips data for employer report$/) do
  DriversShift.create(driver_id: @driver_1.id, vehicle_id: @vehicle_1.id, start_time: 3.days.ago, end_time: 3.hours.from_now)
end

Given(/^Create daily trip route exceptions data for employer report$/) do
  TripRouteException.create(trip_route_id: @trip_1.trip_routes.first.id, date: @trip_time_1, exception_type: :employee_no_show, status: :closed, resolved_date: @trip_time_1 - 5.minutes)
end

Given(/^Complete trips for employer report$/) do
  @employee_trip_0.update(status: :completed)
  @trip_0.update(status: :completed, completed_date: @trip_time_0 - 1.minutes, real_duration: 1.minutes)
  @employee_trip_1.update(status: :completed)
  @trip_1.update(status: :completed, completed_date: @trip_time_1 - 1.minutes, real_duration: 1.minutes)
end

Given(/^I set calendar dates for employer reports$/) do
  page.execute_script("$('.calendar.left .input-mini.form-control.active').val(\"#{1.month.ago.strftime('%d/%m/%Y %l:%M %p')}\").change()")
  sleep(1)
  page.execute_script("$('.calendar.right .input-mini.form-control').val(\"#{1.month.from_now.strftime('%d/%m/%Y %l:%M %p')}\").change()")
  sleep(1)
  page.find('button.applyBtn.btn.btn-sm.btn-primary').click
  sleep(2)
end

Then(/^I can see standard employer reports trip logs$/) do
  page.execute_script("$('a[href=#trip-logs]').click()")
  sleep(1)
  step 'I can see trip logs in employer reports'
end

Then(/^I can see trip logs in employer reports$/) do
  page.find('#trip-logs-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-trip-logs-table th:nth-child(2)').text.should eq("Trip Id")
  page.find('#reports-trip-logs-table tr:nth-child(1) td:nth-child(2)').text.should eq("2")
  page.find('#reports-trip-logs-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
  page.find('#reports-trip-logs-table th:nth-child(2)').click
  sleep(2)
  page.find('#reports-trip-logs-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-trip-logs-table tr:nth-child(2) td:nth-child(2)').text.should eq("2")
end

Then(/^I can see standard employer reports employee logs$/) do
  page.execute_script("$('a[href=#employee-logs]').click()")
  sleep(1)
  step 'I can see employee log in employer reports'
end

Then /^I should get a download with the trip logs filename$/ do
  date = Time.now.strftime('%Y-%m-%d')
  trip_file = "trip_logs-#{date}.csv"
  puts 'I should get a download with the filename "'+trip_file+'"'
  step 'I should get a download with the filename "'+trip_file+'"'
end

Then(/^I can see employee log in employer reports$/) do
  page.find('#employee-logs-picker').click
  step 'I set calendar dates for employer reports'
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

Then(/^I can see standard employer reports employee satisfaction$/) do
  page.execute_script("$('a[href=#employee-satisfaction]').click()")
  sleep(1)
  step 'I can see employee satisfaction in employer reports'
end

Then(/^I can see employee satisfaction in employer reports$/) do
  page.find('#employee-satisfaction-picker').click
  step 'I set calendar dates for employer reports'
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

Then(/^I can see standard employer reports operations summary$/) do
  page.execute_script("$('a[href=#operations-summary]').click()")
  sleep(1)
  step 'I can see operations summary in employer reports'
end

Then(/^I can see operations summary in employer reports$/) do
  page.find('#operations-summary-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-operations-summary-table th:nth-child(2)').text.should eq("Total Trips")
  page.find('#reports-operations-summary-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-operations-summary-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
end

Then(/^I can see standard employer reports no show and cancellations$/) do
  page.execute_script("$('a[href=#no-show-and-cancellations]').click()")
  sleep(1)
  step 'I can see no show and cancellations in employer reports'
end

Then(/^I can see no show and cancellations in employer reports$/) do
  page.find('#no-show-and-cancellations-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-no-show-and-cancellations-table th:nth-child(2)').text.should eq("Total Employees")
  page.find('#reports-no-show-and-cancellations-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-no-show-and-cancellations-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
end

Then(/^I can see standard employer reports trip exceptions$/) do
  page.execute_script("$('a[href=#trip-exceptions]').click()")
  sleep(1)
  step 'I can see trip exceptions in employer reports'
end

Then(/^I can see trip exceptions in employer reports$/) do
  page.find('#trip-exceptions-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-trip-exceptions-table th:nth-child(2)').text.should eq("Total Trips")
  page.find('#reports-trip-exceptions-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-trip-exceptions-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
end

Then(/^I can see standard employer reports on time arrivals$/) do
  page.execute_script("$('a[href=#on-time-arrivals]').click()")
  sleep(1)
  step 'I can see on time arrivals in employer reports'
end

Then(/^I can see on time arrivals in employer reports$/) do
  page.find('#on-time-arrivals-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-on-time-arrivals-table th:nth-child(2)').text.should eq("Total Logins")
  page.find('#reports-on-time-arrivals-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
  page.find('#reports-on-time-arrivals-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
end

Then(/^Set business associate of driver$/) do
  driver = Driver.last
  driver.update_attributes(business_associate: BusinessAssociate.last)
  driver.save!
  driver.vehicle.update_attributes(business_associate: BusinessAssociate.last)
  driver.vehicle.save!
end

Then(/^I can see standard employer reports vehicle deployment$/) do
  page.execute_script("$('a[href=#vehicle-deployment]').click()")
  sleep(1)
  step 'I can see vehicle deployment in employer reports'
end

Then(/^I can see vehicle deployment in employer reports$/) do
  page.find('#vehicle-deployment-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-vehicle-deployment-table th:nth-child(5)').text.should eq("Vehicle Deployed")
  page.find('#reports-vehicle-deployment-table tr:nth-child(1) td:nth-child(5)').text.should eq("1")
  page.find('#reports-vehicle-deployment-table tr:nth-child(2) td:nth-child(5)').text.should eq("1")
end

Then(/^I can see standard employer reports vehicle utilisation$/) do
  page.execute_script("$('a[href=#vehicle-utilisation]').click()")
  sleep(1)
  step 'I can see vehicle utilisation in employer reports'
end

Then(/^I can see vehicle utilisation in employer reports$/) do
  page.find('#vehicle-utilisation-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-vehicle-utilisation-table th:nth-child(5)').text.should eq("Total Planned KMS")
  page.find('#reports-vehicle-utilisation-table th:nth-child(6)').text.should eq("Total Actual KMS")
  page.find('#reports-vehicle-utilisation-table tr:nth-child(1) td:nth-child(5)').text.should eq("24 km")
  page.find('#reports-vehicle-utilisation-table tr:nth-child(1) td:nth-child(6)').text.should eq("24 km")
  page.find('#reports-vehicle-utilisation-table tr:nth-child(2) td:nth-child(5)').text.should eq("24 km")
  page.find('#reports-vehicle-utilisation-table tr:nth-child(2) td:nth-child(6)').text.should eq("24 km")
end

Then(/^I can see standard employer reports OTD$/) do
  page.execute_script("$('a[href=#otd]').click()")
  sleep(1)
  step 'I can see OTD in employer reports'
end

Then(/^I can see OTD in employer reports$/) do
  page.find('#otd-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-otd-table th:nth-child(6)').text.should eq("Scheduled Depature Time")
  page.find('#reports-otd-table th:nth-child(7)').text.should eq("Actual Depature Time")
  page.find('#reports-otd-table tr:nth-child(1) td:nth-child(2)').text.should eq("2")
  page.find('#reports-otd-table tr:nth-child(2) td:nth-child(2)').text.should eq("1")
end

Then(/^I can see standard employer reports OTA$/) do
  page.execute_script("$('a[href=#ota]').click()")
  sleep(1)
  step 'I can see OTA in employer reports'
end

Then(/^I can see OTA in employer reports$/) do
  page.find('#ota-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-ota-table th:nth-child(7)').text.should eq("Scheduled End Time")
  page.find('#reports-ota-table th:nth-child(8)').text.should eq("Actual End Time")
  page.find('#reports-ota-table tr:nth-child(1) td:nth-child(2)').text.should eq("1")
end

# Issue.548
Then(/^I can see correct shift time in vehicle deployment in employer reports$/) do
  page.find('#vehicle-deployment-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-vehicle-deployment-table th:nth-child(3)').text.should eq("Shift Time")
  page.find('#reports-vehicle-deployment-table tr:nth-child(1) td:nth-child(3)').text.should eq(Trip.all[0].planned_date.localtime.strftime('%I:%M'))
  page.find('#reports-vehicle-deployment-table tr:nth-child(2) td:nth-child(3)').text.should eq(Trip.all[0].planned_date.localtime.strftime('%I:%M'))
end

When(/^I change the date for employer reports for vehicle deployment$/) do
  page.find('#vehicle-deployment-picker').click
  page.execute_script("$('.calendar.left .input-mini.form-control.active').val(\"#{1.day.from_now.strftime('%d/%m/%Y %l:%M %p')}\").change()")
  sleep(1)
  page.execute_script("$('.calendar.right .input-mini.form-control').val(\"#{1.month.from_now.strftime('%d/%m/%Y %l:%M %p')}\").change()")
  sleep(1)
  page.find('button.applyBtn.btn.btn-sm.btn-primary').click
  sleep(2)
  page.find('#reports-vehicle-deployment-table th:nth-child(5)').text.should eq("Vehicle Deployed")
end

# Issue.550
Then(/^I can see correct Delta In Arrival At Site for OTA in employer reports$/) do
  page.find('#reports-ota-table th:nth-child(9)').text.should eq("Delta In Arrival At Site")
  delay = page.find('#reports-ota-table tr:nth-child(1) td:nth-child(9)').text
  delay = delay[0..-1].to_i
  delay.should be < 0 
end

Then(/^I can see correct Actual Depature Time At Site for OTD in employer reports$/) do
  page.execute_script("$('a[href=#otd]').click()")
  sleep(1)
  page.find('#otd-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-otd-table th:nth-child(8)').text.should eq("Actual Depature Time")
  delay = page.find('#reports-otd-table tr:nth-child(1) td:nth-child(8)').text
  delay[0..-1].to_i.should be > 0 
end

#Issue.562
When(/^I create employee no show data for employer report$/) do
  step 'Create operator for the employer report'
  step 'Create site for employer report'
  step 'Create employees for employer report'
  step 'Create vehicle for employer report'
  step 'Create driver for employer report'
  step 'Create daily employee trips for employer report'
  step 'Create daily trips for employer report'
  @employee_trip_0.update(status: :missed)
  # @trip_0.update(status: :canceled, completed_date: @trip_time_0 - 1.minutes, real_duration: 1.minutes)
  TripRoute.all[0].update(status: :missed, missed_date: @trip_time_0 - 1.minutes)
  @employee_trip_1.update(status: :canceled)
  # @trip_1.update(status: :canceled, completed_date: @trip_time_1 - 1.minutes, real_duration: 1.minutes)
  TripRoute.all[1].update(status: :missed, missed_date: @trip_time_1 - 1.minutes)
end

Then(/^I can see standard employee no show reports$/) do
  page.execute_script("$('a[href=#employee-no-show]').click()")
  sleep(1)
  page.find('#employee-no-show-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-employee-no-show-table th:nth-child(5)').text.should eq("Employee ID")
  page.find('#reports-employee-no-show-table tr:nth-child(1) td:nth-child(5)').text.should eq("ID233E3")
  page.find('#reports-employee-no-show-table tr:nth-child(2) td:nth-child(5)').text.should eq("ID233E3")
end

#Issue.564

Given(/^I create cancelled trip data for employer report for check in$/) do
  step 'Create basic entities for trips'
  step 'Create daily employee trips for employer report'
  step 'Create daily trips for employer report'
  @employee_trip_0.update(status: :canceled)
  @trip_0.update(status: :canceled, completed_date: @trip_time_0 - 1.minutes, real_duration: 1.minutes)
  @employee_trip_1.update(status: :canceled)
  @trip_1.update(status: :canceled, completed_date: @trip_time_1 - 1.minutes, real_duration: 1.minutes)
end


When(/^Create basic entities for trips$/) do
  step 'Create operator for the employer report'
  step 'Create site for employer report'
  step 'Create employees for employer report'
  step 'Create vehicle for employer report'
  step 'Create driver for employer report'
end

When(/^Create daily employee trips and trips for employer report for check out$/) do
  @trip_time_2 = Time.now - 49.hour
  @employee_trip_2 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_1.id, trip_type: 1, status: 'trip_created', state: 1, schedule_date: @trip_time_2, bus_rider: false, date: @trip_time_2, rating: 4)
  @trip_2 = Trip.create(site_id: @site.id, trip_type: 1, status: 'active', employee_trip_ids: [@employee_trip_2.id], driver: @driver_1, vehicle: @vehicle_1, start_date: @trip_time_2 + 15.minutes)
  @employee_trip_2.update(trip_id: @trip_2.id, trip_route_id: @trip_2.trip_routes.first.id)

  @trip_time_3 = Time.now - 70.hour
  @employee_trip_3 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_1.id, trip_type: 1, status: 'trip_created', state: 1, schedule_date: @trip_time_3, bus_rider: false, date: @trip_time_3, rating: 4)
  @trip_3 = Trip.create(site_id: @site.id, trip_type: 1, status: 'active', employee_trip_ids: [@employee_trip_3.id], driver: @driver_1, vehicle: @vehicle_1, start_date: @trip_time_3 + 15.minutes)
  @employee_trip_3.update(trip_id: @trip_3.id, trip_route_id: @trip_3.trip_routes.first.id)
end

Given(/^I create canceled trip data for employer report for check out$/) do
  # step 'Create basic entities for trips'
  step 'Create daily employee trips and trips for employer report for check out'
  
  @employee_trip_2.update(status: :canceled)
  @trip_2.update(status: :canceled, completed_date: @trip_time_2 + 30.minutes, real_duration: 1.minutes)

  @employee_trip_3.update(status: :canceled)
  @trip_3.update(status: :canceled, completed_date: @trip_time_3 + 30.minutes, real_duration: 1.minutes)
end

Given(/^I create completed trip data for employer report for check out$/) do
  step 'Create basic entities for trips'
  step 'Create daily employee trips and trips for employer report for check out'
  
  @employee_trip_2.update(status: :completed)
  @trip_2.update(status: :completed, completed_date: @trip_time_2 + 30.minutes, real_duration: 1.minutes)

  @employee_trip_3.update(status: :completed)
  @trip_3.update(status: :completed, completed_date: @trip_time_3 + 30.minutes, real_duration: 1.minutes)
end

Then(/^I can see logins canceled in on time arrivals in employer reports$/) do
  page.execute_script("$('a[href=#on-time-arrivals]').click()")
  sleep(1)
  page.find('#on-time-arrivals-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-on-time-arrivals-table th:nth-child(4)').text.should eq("Logins Cancelled")
  page.find('#reports-on-time-arrivals-table tr:nth-child(1) td:nth-child(4)').text.should eq("1")
  page.find('#reports-on-time-arrivals-table tr:nth-child(2) td:nth-child(4)').text.should eq("1")
end

Then(/^I can see logouts canceled in otd summary in employer reports$/) do
  page.execute_script("$('a[href=#otd-summary]').click()")
  sleep(1)
  page.find('#otd-summary-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-otd-summary-table th:nth-child(4)').text.should eq("Logouts Canceled")
  page.find('#reports-otd-summary-table tr:nth-child(1) td:nth-child(4)').text.should eq("1")
  page.find('#reports-otd-summary-table tr:nth-child(2) td:nth-child(4)').text.should eq("1")
end

Then(/^I can see non-zero average delay in logout$/) do
  page.execute_script("$('a[href=#otd-summary]').click()")
  sleep(1)
  page.find('#otd-summary-picker').click
  step 'I set calendar dates for employer reports'
  page.find('#reports-otd-summary-table th:nth-child(6)').text.should eq("Average Delay")
  delay = page.find('#reports-otd-summary-table tr:nth-child(1) td:nth-child(6)').text
  delay = delay[0..-2].to_i
  delay.should be > 0
end