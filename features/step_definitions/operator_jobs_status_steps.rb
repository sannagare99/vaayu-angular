require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given(/^I create data for operator jobs status$/) do
	step 'Create operator for operator job status'
	step 'Create site for operator job status'
	step 'Create employees for operator jobs status'
	step 'Create vehicle for operator jobs status'
	step 'Create driver for operator jobs status'
	step 'Create employee trips for operator jobs status'
	step 'Create trips for operator jobs status'
end

Given(/^Create operator for operator job status$/) do
	@operator = FactoryGirl.create(:operator, logistics_company: @logistics_company)
end


Given(/^I create data for operator jobs status with exception$/) do
	step 'I create data for operator jobs status'
	step 'I create notifications data for operator jobs status'
	step "Driver: create employee no show trip exception request for trip id #{@trip_2.trip_routes.first.id}"
end

Given(/^I create notifications data for operator jobs status$/) do
	@trip_2_notification_1 = FactoryGirl.create(:notification, trip: @trip_2, driver: @driver_1, employee: nil)
	@trip_3_notification_1 = FactoryGirl.create(:notification, trip: @trip_3, driver: @driver_2, employee: nil)
end

Given(/^Create site for operator job status$/) do
	address = 'Shubham Complex, Opposite ESIS Hospital, Akurli Road, Akurli Industry Estate, Kandivali East, Mumbai, Maharashtra 400101, India'
	@site = FactoryGirl.create(:site, employee_company: @employee_company, address: address, latitude: 19.2013359, longitude: 72.855722)
end


Given(/^Create employees for operator jobs status$/) do
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

Given(/^Create vehicle for operator jobs status$/) do
	device_id_1 = 'd001'
	plate_number_1 = 'MH12301'
	@vehicle_1 = FactoryGirl.create(:vehicle, plate_number: plate_number_1, device_id: device_id_1)

	device_id_2 = 'd002'
	plate_number_2 = 'MH12302'
	@vehicle_2 = FactoryGirl.create(:vehicle, plate_number: plate_number_2, device_id: device_id_2)
end

Given(/^Create driver for operator jobs status$/) do
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

Given(/^Create employee trips for operator jobs status$/) do
	@trip_time_2 = Time.now + 15.minutes
	@trip_time_3 = Time.now + 2.hour
	@employee_trip_3 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_3.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_2, bus_rider: false, date: @trip_time_2)
	@employee_trip_4 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_4.id, trip_type: 0, status: 'current', state: 1, schedule_date: @trip_time_2, bus_rider: false, date: @trip_time_2)
	@employee_trip_5 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_5.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_2, bus_rider: false, date: @trip_time_2)
	@employee_trip_6 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_6.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_3, bus_rider: false, date: @trip_time_3)
end

Given(/^Create trips for operator jobs status$/) do
	@trip_2 = Trip.create(site_id: @site.id, trip_type: 0, status: 'active', employee_trip_ids: [@employee_trip_3.id, @employee_trip_4.id, @employee_trip_5.id], driver: @driver_1, vehicle: @vehicle_1)
	@employee_trip_3.update(trip_id: @trip_2.id, trip_route_id: @trip_2.trip_routes.first.id)
	@employee_trip_4.update(trip_id: @trip_2.id, trip_route_id: @trip_2.trip_routes.first.id)
	@employee_trip_5.update(trip_id: @trip_2.id, trip_route_id: @trip_2.trip_routes.first.id)
	@trip_3 = Trip.create(site_id: @site.id, trip_type: 0, status: 'assign_requested', employee_trip_ids: [@employee_trip_6.id], driver: @driver_2, vehicle: @vehicle_2)
	@employee_trip_6.update(trip_id: @trip_3.id, trip_route_id: @trip_3.trip_routes.first.id)
end

Then(/^I should see correct status for every trip in status table for operator jobs$/) do
	page.find('#trips-notifications-table tr:nth-child(1) td:nth-child(2)').text.should eq("#{@trip_time_3.strftime('%m/%d/%Y')} - #{@trip_3.id}")
	page.find('#trips-notifications-table tr:nth-child(1) td:nth-child(5)').text.should eq('Driver Accepted Trip')
	page.find('#trips-notifications-table tr:nth-child(2) td:nth-child(2)').text.should eq("#{@trip_time_2.strftime('%m/%d/%Y')} - #{@trip_2.id}")
	page.find('#trips-notifications-table tr:nth-child(2) td:nth-child(5)').text.should eq('Passanger No Show')
end

Then(/^I should see alerted trip in status table for operator job$/) do
	page.find('#trips-notifications-table tr:nth-child(2) td:nth-child(2)').should have_css('.bg-notification')
end

Then(/^I should see notification history of a trip in status table for operator job$/) do
	@trip_2_notification_2 = Notification.where(message: 'employee_no_show').first
	page.find('#trips-notifications-table tr:nth-child(2) td:nth-child(1)').find('i.fa.fa-plus').click
	page.find('#trips-notifications-table tr:nth-child(2) td:nth-child(3)').text.should eq(@trip_2_notification_2.created_at.localtime.strftime('%m/%d/%Y %I:%M%p'))
	page.find('#trips-notifications-table tr:nth-child(2) td:nth-child(5)').text.should eq('Passanger No Show')
	page.find('table.table.table-bordered.child-table tr:nth-child(1) td:nth-child(3)').text.should eq(@trip_2_notification_1.created_at.localtime.strftime('%m/%d/%Y %I:%M%p'))
	page.find('table.table.table-bordered.child-table tr:nth-child(1) td:nth-child(5)').text.should eq('Driver Accepted Trip')
end

Then(/^I should see actions of a trip in status table for operator job$/) do
	page.find('#trips-notifications-table tr:nth-child(1) td:nth-child(4)').text.should eq('--')
	page.find('#trips-notifications-table tr:nth-child(1) td:nth-child(6)').text.should eq('')
	page.find('#trips-notifications-table tr:nth-child(2) td:nth-child(4)').should have_css('.call-div.bg-primary')
	page.find('#trips-notifications-table tr:nth-child(2) td:nth-child(6)').text.should eq('Move To Next Step')
	page.find('#trips-notifications-table tr:nth-child(2) td:nth-child(6)').should have_css('a#move_to_next_step')
end