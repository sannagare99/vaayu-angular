require File.expand_path(File.join(File.dirname(__FILE__), "../../", "support", "paths"))

Then(/^I hover over the element "([^"]*)" of Trip "([^"]*)" it shows the tooltip "([^"]*)"$/) do |link,index,content|
  sleep(3)
  el = page.all('#driver-schedule-timeline .vis-group')[index.to_i].find(link)
  page.driver.browser.action.move_to(el.native).perform
  page.should have_content content
end

Then(/^I double click on the element "([^"]*)" of Trip "([^"]*)" it shows the tooltip "([^"]*)"$/) do |link,index,content|
  sleep(3)
  el = page.all('#driver-schedule-timeline .vis-group')[index.to_i].find(link)
  el.double_click
  sleep(10)
  page.should have_content content
end

Given(/^I create data for employer jobs trip board$/) do
	step 'Create site for employer job trip board'
	step 'Create employees for employer jobs trip board'
	step 'Create vehicle for employer jobs trip board'
	step 'Create driver for employer jobs trip board'
	step 'Create employee trips for employer jobs trip board'
	step 'Create trips for employer jobs trip board'
end

Given(/^I create data for employer jobs trip board with exception$/) do
	step 'I create data for employer jobs trip board'
	step 'I create notifications data for employer trip boards'
	step "Driver: create employee no show trip exception request for trip id #{@trip_2.trip_routes.first.id}"
end

Given(/^Create site for employer job trip board$/) do
	address = 'Shubham Complex, Opposite ESIS Hospital, Akurli Road, Akurli Industry Estate, Kandivali East, Mumbai, Maharashtra 400101, India'
	@site = FactoryGirl.create(:site, employee_company: @employee_company, address: address, latitude: 19.2013359, longitude: 72.855722)
end

Given(/^I create notifications data for employer trip boards$/) do
	@trip_2_notification_1 = FactoryGirl.create(:notification, trip: @trip_2, driver: @driver_1, employee: nil, message: 'active')
	@trip_3_notification_1 = FactoryGirl.create(:notification, trip: @trip_3, driver: @driver_2, employee: nil, message: 'operator_assigned_trip')
end

Given(/^Create employees for employer jobs trip board$/) do
	address_3 = '2nd Floor, Kenilworth Mall, Phase 2, Off Linking Road, Behind KFC, Bandra West, Bandra West, Mumbai, Maharashtra 400050, India'
	address_4 = '30, Lourdes Heaven, 30th Rd, Bandra West, Pali Village, Bandra West, Mumbai, Maharashtra 400050, India'
	address_5 = '3rd Floor, Link Square Mall, Linking Road, Above Global Fusion, Bandra West, Bandra West, Mumbai, Maharashtra 400050, India'
	address_6 = 'Plot 339, 16th Road, Bandra West, Pali Village, Bandra West, Mumbai, Maharashtra 400050, India'
	id_3 = 'ID233E3'
	id_4 = 'ID233E4'
	id_5 = 'ID233E5'
	id_6 = 'ID233E6'
	@employee_3 = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company, employee_id: id_3, home_address: address_3)
	@employee_4 = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company, employee_id: id_4, home_address: address_4)
	@employee_5 = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company, employee_id: id_5, home_address: address_5)
	@employee_6 = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company, employee_id: id_6, home_address: address_6)
end

Given(/^Create vehicle for employer jobs trip board$/) do
	device_id_1 = 'd001'
	plate_number_1 = 'MH12301'
	@vehicle_1 = FactoryGirl.create(:vehicle, plate_number: plate_number_1, device_id: device_id_1)

	device_id_2 = 'd002'
	plate_number_2 = 'MH12302'
	@vehicle_2 = FactoryGirl.create(:vehicle, plate_number: plate_number_2, device_id: device_id_2)
end

Given(/^Create driver for employer jobs trip board$/) do
	address_1 = 'Shop No. 4, Mishra House, Khar West, Chitrakar Dhurandhar Road, Ram Krishna Nagar, Ram Krishna Nagar, Khar West, Mumbai, Maharashtra 400052, India'
	badge_number_1 = 'ABC'
	aadhaar_number_1 = '123'
	licence_number_1 = 'ABCDEFGHIJ12345'
	@driver_1 = FactoryGirl.create(:driver, site: @site, logistics_company: @logistics_company, permanent_address: address_1, local_address: address_1, badge_number: badge_number_1, aadhaar_number: aadhaar_number_1, licence_number: licence_number_1, vehicle: @vehicle_1)
	@auth_token_driver = @driver_1.user.create_new_auth_token

	address_2 = 'The Unicontinental, Nr. Khar Railway Station, 3rd Road, Khar West, Ram Krishna Nagar, Khar West, Mumbai, Maharashtra 400022, India'
	badge_number_2 = 'DEF'
	aadhaar_number_2 = '456'
	licence_number_2 = 'ABCDEFGHIJ67890'
	@driver_2 = FactoryGirl.create(:driver, site: @site, logistics_company: @logistics_company, permanent_address: address_2, local_address: address_2, badge_number: badge_number_2, aadhaar_number: aadhaar_number_2, licence_number: licence_number_2, vehicle: @vehicle_2)
end

Given(/^Create employee trips for employer jobs trip board$/) do
	@trip_time_2 = Time.now + 15.minutes
	@trip_time_3 = Time.now + 2.hour
	@employee_trip_3 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_3.id, trip_type: 0, status: 'current', state: 1, schedule_date: @trip_time_2, bus_rider: false, date: @trip_time_2)
	@employee_trip_4 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_4.id, trip_type: 0, status: 'current', state: 1, schedule_date: @trip_time_2, bus_rider: false, date: @trip_time_2)
	@employee_trip_5 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_5.id, trip_type: 0, status: 'current', state: 1, schedule_date: @trip_time_2, bus_rider: false, date: @trip_time_2)
	@employee_trip_6 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_6.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_3, bus_rider: false, date: @trip_time_3)
end

Given(/^Create trips for employer jobs trip board$/) do
	@trip_2 = Trip.create(site_id: @site.id, trip_type: 0, status: 'active', employee_trip_ids: [@employee_trip_3.id, @employee_trip_4.id, @employee_trip_5.id], driver: @driver_1, vehicle: @vehicle_1)
	@trip_3 = Trip.create(site_id: @site.id, trip_type: 0, status: 'assign_requested', employee_trip_ids: [@employee_trip_6.id], driver: @driver_2, vehicle: @vehicle_2)
end

Then(/^I should see alerted trips in correct priority order on trip timeline for employer jobs trip board$/) do
	page.find('#driver-schedule-timeline').find('div.vis-item.vis-range.error-trip.vis-readonly').find('#open-modal').text.should eq("# #{@trip_time_2.strftime('%Y %m %d')} - #{@trip_2.id}")
	page.find('#driver-schedule-timeline').find('div.vis-item.vis-range.completed-trip.vis-readonly').find('#open-modal').text.should eq("# #{@trip_time_3.strftime('%Y %m %d')} - #{@trip_3.id}")
	page.evaluate_script("$('div.vis-item.vis-range.error-trip.vis-readonly').offset().top").should < page.evaluate_script("$('div.vis-item.vis-range.completed-trip.vis-readonly').offset().top")
end