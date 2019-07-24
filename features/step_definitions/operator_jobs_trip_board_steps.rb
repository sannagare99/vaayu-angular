require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given(/^I create data for operator jobs trip board$/) do
	step 'Create site for operator job trip board'
	step 'Create employees for operator jobs trip board'
	step 'Create vehicle for operator jobs trip board'
	step 'Create driver for operator jobs trip board'
	step 'Create employee trips for operator jobs trip board'
	step 'Create trips for operator jobs trip board'
end

Given(/^I create data for operator jobs trip board with exception$/) do
	step 'I create data for operator jobs trip board'
	step 'I create notifications data for operator trip boards'
	step "Driver: create employee no show trip exception request for trip id #{@trip_2.trip_routes.first.id}"
end

Given(/^Create site for operator job trip board$/) do
	address = 'Shubham Complex, Opposite ESIS Hospital, Akurli Road, Akurli Industry Estate, Kandivali East, Mumbai, Maharashtra 400101, India'
	@site = FactoryGirl.create(:site, employee_company: @employee_company, address: address, latitude: 19.2013359, longitude: 72.855722)
end

Given(/^I create notifications data for operator trip boards$/) do
	@trip_2_notification_1 = FactoryGirl.create(:notification, trip: @trip_2, driver: @driver_1, employee: nil, message: 'active')
	@trip_3_notification_1 = FactoryGirl.create(:notification, trip: @trip_3, driver: @driver_2, employee: nil, message: 'operator_assigned_trip')
end

Given(/^Create employees for operator jobs trip board$/) do
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

Given(/^Create vehicle for operator jobs trip board$/) do
	device_id_1 = 'd001'
	plate_number_1 = 'MH12301'
	@vehicle_1 = FactoryGirl.create(:vehicle, plate_number: plate_number_1, device_id: device_id_1)

	device_id_2 = 'd002'
	plate_number_2 = 'MH12302'
	@vehicle_2 = FactoryGirl.create(:vehicle, plate_number: plate_number_2, device_id: device_id_2)
end

Given(/^Create driver for operator jobs trip board$/) do
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

Given(/^Create employee trips for operator jobs trip board$/) do
	@trip_time_2 = Time.now + 15.minutes
	@trip_time_3 = Time.now + 2.hour
	@employee_trip_3 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_3.id, trip_type: 0, status: 'current', state: 1, schedule_date: @trip_time_2, bus_rider: false, date: @trip_time_2)
	@employee_trip_4 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_4.id, trip_type: 0, status: 'current', state: 1, schedule_date: @trip_time_2, bus_rider: false, date: @trip_time_2)
	@employee_trip_5 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_5.id, trip_type: 0, status: 'current', state: 1, schedule_date: @trip_time_2, bus_rider: false, date: @trip_time_2)
	@employee_trip_6 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_6.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_3, bus_rider: false, date: @trip_time_3)
end

Given(/^Create trips for operator jobs trip board$/) do
	@trip_2 = Trip.create(site_id: @site.id, trip_type: 0, status: 'active', employee_trip_ids: [@employee_trip_3.id, @employee_trip_4.id, @employee_trip_5.id], driver: @driver_1, vehicle: @vehicle_1)
	@trip_3 = Trip.create(site_id: @site.id, trip_type: 0, status: 'assign_requested', employee_trip_ids: [@employee_trip_6.id], driver: @driver_2, vehicle: @vehicle_2)
end

Then(/^I should see active and inactive on trip timeline$/) do
	page.find('#driver-schedule-timeline').find('div.vis-item.vis-range.active-trip.vis-readonly').find('#open-modal').text.should eq("# #{@trip_time_2.strftime('%Y %m %d')} - #{@trip_2.id}")
	page.find('#driver-schedule-timeline').find('div.vis-item.vis-range.resolved-trip.vis-readonly').find('#open-modal').text.should eq("# #{@trip_time_3.strftime('%Y %m %d')} - #{@trip_3.id}")
end

Then(/^I should see alerted trips in correct priority order on trip timeline$/) do
	page.find('#driver-schedule-timeline').find('div.vis-item.vis-range.error-trip.vis-readonly').find('#open-modal').text.should eq("# #{@trip_time_2.strftime('%Y %m %d')} - #{@trip_2.id}")
	page.find('#driver-schedule-timeline').find('div.vis-item.vis-range.completed-trip.vis-readonly').find('#open-modal').text.should eq("# #{@trip_time_3.strftime('%Y %m %d')} - #{@trip_3.id}")
	page.evaluate_script("$('div.vis-item.vis-range.error-trip.vis-readonly').offset().top").should < page.evaluate_script("$('div.vis-item.vis-range.completed-trip.vis-readonly').offset().top")
end

Then(/^I should see correct hover text of trips on trip timeline$/) do
	page.find('#driver-schedule-timeline').find('div.vis-item.vis-range.error-trip.vis-readonly').find('#open-modal').hover
	page.find('div.popover-content').text.should eq('Employee No Show')
end


And(/^I click on alerted trip$/) do
	page.find('#driver-schedule-timeline').find('div.vis-item.vis-range.error-trip.vis-readonly').find('#open-modal').double_click
end

Then(/^I should see all correct trip action for the alerted trip$/) do
	page.find('.modal').find('#trip-info-content-table tr:nth-child(1) td:nth-child(1)').should have_css('div.call-div.bg-danger')
	page.find('.modal').first('p.driver-name.cf-label').text.should eq @driver_1.user.f_name + " " + @driver_1.user.l_name
	page.find('.modal-footer').find('button#complete_with_exception').text.should eq "Complete with Exception"
	page.find('.modal-footer').find('a#move_driver_to_next_step').text.should eq "Move To Next Step"
end

Then(/^I should be able to confirm the alerted trip with exception$/) do
	page.find('button#complete_with_exception').click
	step "Wait for modal \"#{@trip_time_2.strftime('%Y/%m/%d')} - #{@trip_2.id}\""
	page.find(:xpath, "//label[@for='complete_with_exception_2']").click
	page.find('a#complete-with-exception-submit').click
	# TODO: [BUG] Notification is not created when operator submit complete with exceptions, remove the following lines when bug fixed in TripsController#complete_with_exception_submit
	sleep(3)
	@trip_2_notification_1 = FactoryGirl.create(:notification, trip: @trip_2, driver: @driver_1, employee: nil, message: 'canceled')
	page.execute_script("window.location.reload()")
	sleep(2)
	# END of block to be deleted when bug fixed
	page.find('#driver-schedule-timeline').all('div.vis-item.vis-range.completed-trip.vis-readonly')[0].find('#open-modal').hover
	page.find('div.popover-content').text.should eq('Trip Canceled')
end

Then(/^I should be able to move to next step for alerted trip$/) do
	page.find('a#move_driver_to_next_step').click
	page.find('#driver-schedule-timeline').find('div.vis-item.vis-range.active-trip.vis-readonly').find('#open-modal').hover
	page.find('div.popover-content').text.should eq('Active Trip')
end