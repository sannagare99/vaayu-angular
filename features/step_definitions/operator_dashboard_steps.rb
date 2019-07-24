require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given(/^I create data for daily macro parameters in the operator dashboard$/) do
	step 'Create operator for the operator dashboard'
	step 'Create site for operator dashboard'
	step 'Create employees for operator dashoard'
	step 'Create vehicle for operator dashboard'
	step 'Create driver for operator dashboard'
	step 'Create daily employee trips for operator dashboard'
	step 'Create daily trips for operator dashboard'
	step 'Create daily driver shifts trips data for operator dashboard'
	step 'Create daily trip route exceptions data for operator dashboard'
end

Given(/^Create operator for the operator dashboard$/) do
	@operator = FactoryGirl.create(:operator, logistics_company: @logistics_company)
end

Given(/^Create site for operator dashboard$/) do
	address = 'Shubham Complex, Opposite ESIS Hospital, Akurli Road, Akurli Industry Estate, Kandivali East, Mumbai, Maharashtra 400101, India'
	@site = FactoryGirl.create(:site, employee_company: @employee_company, address: address, latitude: 19.2013359, longitude: 72.855722)
end


Given(/^Create employees for operator dashoard$/) do
	address_1 = '2nd Floor, Kenilworth Mall, Phase 2, Off Linking Road, Behind KFC, Bandra West, Bandra West, Mumbai, Maharashtra 400050, India'
	id_1 = 'ID233E3'
	@employee_1 = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company, employee_id: id_1, home_address: address_1)
end

Given(/^Create vehicle for operator dashboard$/) do
	device_id_1 = 'd001'
	plate_number_1 = 'MH12301'
	@vehicle_1 = FactoryGirl.create(:vehicle, plate_number: plate_number_1, device_id: device_id_1)
end

Given(/^Create driver for operator dashboard$/) do
	address_1 = 'Shop No. 4, Mishra House, Khar West, Chitrakar Dhurandhar Road, Ram Krishna Nagar, Ram Krishna Nagar, Khar West, Mumbai, Maharashtra 400052, India'
	badge_number_1 = 'ABC'
	aadhaar_number_1 = '123'
	licence_number_1 = 'ABCDEFGHIJ12345'
	@driver_1 = FactoryGirl.create(:driver, site: @site, logistics_company: @logistics_company, permanent_address: address_1, local_address: address_1, badge_number: badge_number_1, aadhaar_number: aadhaar_number_1, licence_number: licence_number_1, vehicle: @vehicle_1)
	@auth_token_driver = @driver_1.user.create_new_auth_token
end

Given(/^Create daily employee trips for operator dashboard$/) do
	@trip_time_1 = Time.now - 1.hour
	@employee_trip_1 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_1.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_1, bus_rider: false, date: @trip_time_1, rating: 4)
end

Given(/^Create daily trips for operator dashboard$/) do
	@trip_1 = Trip.create(site_id: @site.id, trip_type: 0, status: 'active', employee_trip_ids: [@employee_trip_1.id], driver: @driver_1, vehicle: @vehicle_1, start_date: @trip_time_1 - 15.minutes)
	@employee_trip_1.update(trip_id: @trip_1.id, trip_route_id: @trip_1.trip_routes.first.id)
end

Given(/^Create daily driver shifts trips data for operator dashboard$/) do
	DriversShift.create(driver_id: @driver_1.id, vehicle_id: @vehicle_1.id, start_time: 3.hours.ago, end_time: 3.hours.from_now)
end

Given(/^Create daily trip route exceptions data for operator dashboard$/) do
	TripRouteException.create(trip_route_id: @trip_1.trip_routes.first.id, date: @trip_time_1, exception_type: :employee_no_show, status: :closed, resolved_date: @trip_time_1 - 5.minutes)
	@employee_trip_1.update(status: :completed)
	@trip_1.update(status: :completed, completed_date: @trip_time_1 - 1.minutes, real_duration: 1.minutes)
end

Then(/^I can see macro parameters in the operator dashboard$/) do
	step 'I can see exceptions macro parameter'
	step 'I can see completed trips macro parameter'
	step 'I can see on time arrivals macro parameter'
	step 'I can see fleet utilization macro parameter'
	step 'I can see employee satisfation macro parameter'
end

Then(/^I can see exceptions macro parameter$/) do
	page.find('#stats-capacity-utilization').find('a').text.should eq('Exceptions')
	parameters = page.find('#stats-capacity-utilization').find('ul.list-group.bg-primary').all('li.list-group-item')
	parameters[0].text.should eq('1 Alarm Raised')
	parameters[1].text.should eq('1 Alarm Resolved')
end

Then(/^I can see completed trips macro parameter$/) do
	page.find('#stats-completed-trips').find('a').text.should eq('Completed Trips')
	parameters = page.find('#stats-completed-trips').find('ul.list-group.bg-primary').all('li.list-group-item')
	parameters[0].text.should eq('23 km Total Distance')
	distance_strings = parameters[1].text.split(' ')
	distance_strings[0].to_i.should eq(23)
	parameters[2].text.should eq('1 h 0 m Duration per Trip')
end

Then(/^I can see on time arrivals macro parameter$/) do
	page.find('#stats-arrivals').find('a').text.should eq('On Time Arrivals')
	parameters = page.find('#stats-arrivals').find('ul.list-group.bg-primary').all('li.list-group-item')
	parameters[0].text.should eq("0\% On-Time Check-in")
	parameters[1].text.should eq("0\% No Show")
	parameters[2].text.should eq("0 min Average Delay")
	parameters[3].text.should eq("0 min Average Wait")
	page.find('#stats-arrivals').find('p.chart-label.text-ellipsis.text-center').text.should eq('On Time Arrival')
	page.find('#stats-arrivals').find('div.easyPieChart').find('span').text.should eq("100\%")
end

Then(/^I can see fleet utilization macro parameter$/) do
	page.find('#stats-fleet-utilization').find('a').text.should eq('Fleet Utilization')
	parameters = page.find('#stats-fleet-utilization').find('ul.list-group.bg-primary').all('li.list-group-item')
	parameters[0].text.should eq("1.0 Trips per Vehicle")
	titles = page.find('#stats-fleet-utilization').all('p.chart-label.text-ellipsis.text-center')
	charts = page.find('#stats-fleet-utilization').all('div.easyPieChart')
	titles[0].text.should eq('Fleet Idleness')
	titles[1].text.should eq('Capacity Utilization')
	charts[0].find('span').text.should eq("1\%")
	charts[1].find('span').text.should eq("20\%")
end

Then(/^I can see employee satisfation macro parameter$/) do
	page.find('#stats-employee-satisfaction').find('a').text.should eq('Employee Satisfaction')
	titles = page.find('#stats-employee-satisfaction').all('p.chart-label.text-ellipsis.text-center')
	titles[0].text.should eq('Average Rating')
	titles[1].text.should eq('Under Expectation')
	page.find('#stats-employee-satisfaction').find('div.easyPieChart').find('span').text.should eq("0\%")
	page.find('#stats-employee-satisfaction').find('div.rating').find('span').text.should eq("4.0")
end

Given(/^I create data for weekly and monthly macro parameters in the operator dashboard$/) do
	step 'Create operator for the operator dashboard'
	step 'Create site for operator dashboard'
	step 'Create employees for operator dashoard'
	step 'Create vehicle for operator dashboard'
	step 'Create driver for operator dashboard'
	step 'Create weekly and monthly employee trips for operator dashboard'
	step 'Create weekly and monthly trips for operator dashboard'
	step 'Create weekly and monthly driver shifts trips data for operator dashboard'
	step 'Create weekly and monthly trip route exceptions data for operator dashboard'
end

Given(/^Create weekly and monthly employee trips for operator dashboard$/) do
	@trip_time_1 = Time.now - 3.days
	@employee_trip_1 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_1.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_1, bus_rider: false, date: @trip_time_1, rating: 4)
end

Given(/^Create weekly and monthly trips for operator dashboard$/) do
	@trip_1 = Trip.create(site_id: @site.id, trip_type: 0, status: 'active', employee_trip_ids: [@employee_trip_1.id], driver: @driver_1, vehicle: @vehicle_1, start_date: @trip_time_1 - 15.minutes)
	@employee_trip_1.update(trip_id: @trip_1.id, trip_route_id: @trip_1.trip_routes.first.id)
end

Given(/^Create weekly and monthly driver shifts trips data for operator dashboard$/) do
	DriversShift.create(driver_id: @driver_1.id, vehicle_id: @vehicle_1.id, start_time: 5.days.ago, end_time: 3.hours.from_now)
end

Given(/^Create weekly and monthly trip route exceptions data for operator dashboard$/) do
	TripRouteException.create(trip_route_id: @trip_1.trip_routes.first.id, date: @trip_time_1, exception_type: :employee_no_show, status: :closed, resolved_date: @trip_time_1 - 5.minutes)
	@employee_trip_1.update(status: :completed)
	@trip_1.update(status: :completed, completed_date: @trip_time_1 - 1.minutes, real_duration: 1.minutes)
end

Then(/^I can see micro parameters in the operator dashboard$/) do
	step 'I can see exceptions micro parameter'
	step 'I can see completed trips micro parameter'
	step 'I can see on time arrivals micro parameter'
	step 'I can see fleet utilization micro parameter'
	step 'I can see employee satisfation micro parameter'
end

Then(/^I can see exceptions micro parameter$/) do
	page.find('#stats-capacity-utilization').find('a').click
	step "Wait for modal \"Exeptions Compliance\""
	page.find('.modal-body').find('p.lead').text.should eq('Exceptions')
	micro_parameters = page.find('.modal-body').find('ul.list-percentages.row').all('li')
	micro_parameters[0].find('p.stat-label.text-ellipsis').text.should eq('Panic')
	micro_parameters[1].find('p.stat-label.text-ellipsis').text.should eq('Not On Board')
	micro_parameters[2].find('p.stat-label.text-ellipsis').text.should eq('Still On Board')
	micro_parameters[3].find('p.stat-label.text-ellipsis').text.should eq('Driver No Show')
	micro_parameters[4].find('p.stat-label.text-ellipsis').text.should eq('Car Broke Down')
	micro_parameters[5].find('p.stat-label.text-ellipsis').text.should eq('Employee No Show')
	micro_parameters[0].find('strong').text.should eq('0')
	micro_parameters[1].find('strong').text.should eq('0')
	micro_parameters[2].find('strong').text.should eq('0')
	micro_parameters[3].find('strong').text.should eq('0')
	micro_parameters[4].find('strong').text.should eq('0')
	micro_parameters[5].find('strong').text.should eq('1')
	page.find('.modal-header').find('button.close').click
end

Then(/^I can see completed trips micro parameter$/) do
	page.find('#stats-completed-trips').find('a').click
	step "Wait for modal \"Stats title\""
	page.find('.modal-body').find('#stats-manifest-fulfilled').find('p.lead').text.should eq('Manifest Fulfilled')
	page.find('.modal-body').find('#stats-manifest-fulfilled').find('p.chart-label').text.should eq('Fulfilled')
	page.find('.modal-body').find('#stats-manifest-fulfilled').find('div.easyPieChart').find('span').text.should eq("100\%")
	page.find('.modal-body').find('#stats-duration').find('p.lead').text.should eq('Duration')
	duration_parameters = page.find('.modal-body').find('#stats-duration').find('ul.list-percentages.row').all('li')
	duration_parameters[0].find('p.stat-label.text-ellipsis').text.should eq('Total Duration')
	duration_parameters[1].find('p.stat-label.text-ellipsis').text.should eq('Duration per Trip')
	duration_parameters[2].find('p.stat-label.text-ellipsis').text.should eq('Duration per Employee')
	duration_parameters[0].find('strong').text.should eq('1 h 0 m')
	duration_parameters[1].find('strong').text.should eq('1 h 0 m')
	duration_parameters[2].find('strong').text.should eq('1 h 0 m')
	page.find('.modal-body').find('#stats-employees-catered').find('p.lead').text.should eq('Employees Catered')
	page.find('.modal-body').find('#stats-employees-catered').find('p.chart-label').text.should eq('Catered')
	page.find('.modal-body').find('#stats-employees-catered').find('div.easyPieChart').find('span').text.should eq("100\%")
	page.find('.modal-body').find('#stats-mileage').find('p.lead').text.should eq('Distance')
	distance_parameters = page.find('.modal-body').find('#stats-mileage').find('ul.list-percentages.row').all('li')
	distance_parameters[0].find('p.stat-label.text-ellipsis').text.should eq('Total Distance')
	distance_parameters[1].find('p.stat-label.text-ellipsis').text.should eq('Distance per Trip')
	distance_parameters[2].find('p.stat-label.text-ellipsis').text.should eq('Distance per Employee')
	distance_parameters[0].find('strong').text.should eq('23 km')
	distance_strings = distance_parameters[1].find('strong').text.split(' ')
	distance_strings[0].to_i.should eq(23)
	distance_strings[1].should eq('km')
	distance_strings = distance_parameters[2].find('strong').text.split(' ')
	distance_strings[0].to_i.should eq(23)
	distance_strings[1].should eq('km')
	page.find('.modal-header').find('button.close').click
end

Then(/^I can see on time arrivals micro parameter$/) do
	page.find('#stats-arrivals').find('a').click
	step "Wait for modal \"On Time Arrivals\""
	titles = page.find('.modal-body').all('h5.stats-block-title')
	titles[0].text.should eq('Pick-Up Trip Deep Dive')
	titles[1].text.should eq('Drop-Off Trip Deep Dive')
	parameters = page.find('.modal-body').all('ul.stats-list.list-unstyled')
	pick_up_parameters = parameters[0]
	pick_up_parameters_list = pick_up_parameters.all('li')
	pick_up_parameters_list[0].find('p.lead').text.should eq('On-Time Check In')
	pick_up_parameters_list[0].find('p.chart-label').text.should eq('On-time')
	pick_up_parameters_list[0].find('div.easyPieChart').find('span').text.should eq("0\%")
	pick_up_parameters_list[1].find('p.lead').text.should eq('On-Time First Pick Up')
	pick_up_parameters_list[1].find('p.chart-label').text.should eq('On-time')
	pick_up_parameters_list[1].find('div.easyPieChart').find('span').text.should eq("0\%")
	pick_up_parameters_list[2].find('p.lead').text.should eq('No Show')
	pick_up_parameters_list[2].find('div.easyPieChart').find('span').text.should eq("0\%")
	pick_up_parameters_list[3].find('p.lead').text.should eq('Delay and Wait')
	delay_and_wait_parameters = pick_up_parameters_list[3].find('ul.list-percentages.row').all('li')
	delay_and_wait_parameters[0].find('p.stat-label.text-ellipsis').text.should eq('Average Delay')
	delay_and_wait_parameters[0].find('strong').text.should eq('0 min')
	delay_and_wait_parameters[1].find('p.stat-label.text-ellipsis').text.should eq('Average Wait')
	delay_and_wait_parameters[1].find('strong').text.should eq('0 min')
	drop_off_parameters = parameters[1]
	drop_off_parameters_list = drop_off_parameters.all('li')
	drop_off_parameters_list[0].find('p.lead').text.should eq('On-Time Check In')
	drop_off_parameters_list[0].find('p.chart-label').text.should eq('On-time')
	drop_off_parameters_list[0].find('div.easyPieChart').find('span').text.should eq("0\%")
	drop_off_parameters_list[1].find('p.lead').text.should eq('On-Time First Pick Up')
	drop_off_parameters_list[1].find('p.chart-label').text.should eq('On-time')
	drop_off_parameters_list[1].find('div.easyPieChart').find('span').text.should eq("0\%")
	drop_off_parameters_list[2].find('p.lead').text.should eq('No Show')
	drop_off_parameters_list[2].find('div.easyPieChart').find('span').text.should eq("0\%")
	drop_off_parameters_list[3].find('p.lead').text.should eq('Delay and Wait')
	delay_and_wait_parameters = drop_off_parameters_list[3].find('ul.list-percentages.row').all('li')
	delay_and_wait_parameters[0].find('p.stat-label.text-ellipsis').text.should eq('Average Delay')
	delay_and_wait_parameters[0].find('strong').text.should eq('0 min')
	delay_and_wait_parameters[1].find('p.stat-label.text-ellipsis').text.should eq('Average Wait')
	delay_and_wait_parameters[1].find('strong').text.should eq('0 min')
	page.find('.modal-header').find('button.close').click
end

Then(/^I can see fleet utilization micro parameter$/) do
	page.find('#stats-fleet-utilization').find('a').click
	step "Wait for modal \"Fleet Utilization\""
	page.find('.modal-body').find('#stats-manifest-fulfilled').find('p.lead').text.should eq('Manifest Fulfilled')
	page.find('.modal-body').find('#stats-manifest-fulfilled').find('p.chart-label').text.should eq('Fulfilled')
	page.find('.modal-body').find('#stats-manifest-fulfilled').find('div.easyPieChart').find('span').text.should eq("100\%")
	page.find('.modal-body').find('#stats-trip').find('p.lead').text.should eq('Trip')
	page.find('.modal-body').find('#stats-trip').find('p.stat-label.text-ellipsis').text.should eq('Trips per Vehicle')
	page.find('.modal-body').find('#stats-trip').find('strong').text.should eq("1.0")
	page.find('.modal-body').find('#stats-fleet-idleness').find('p.lead').text.should eq('Fleet Idleness')
	chart_labels = page.find('.modal-body').find('#stats-fleet-idleness').all('p.chart-label')
	chart_labels[0].text.should eq('1 Active on Delivery')
	chart_labels[1].text.should eq('0 Waiting for Assignment')
	page.find('.modal-body').find('#stats-fleet-idleness').find('div.easyPieChart').find('span').text.should eq("1\%")
	page.find('.modal-header').find('button.close').click
end

Then(/^I can see employee satisfation micro parameter$/) do
	page.find('#stats-employee-satisfaction').find('a').click
	step "Wait for modal \"Employee Satisfaction\""
	page.find('.modal-body').find('#stats-trip').find('p.lead').text.should eq('Average Rating')
	page.find('.modal-body').find('#stats-trip').find('span.rating-count').text.should eq('4.0')
	page.find('.modal-body').find('#stats-trip').find('p.rank-info.text-ellipsis').text.should eq("100.0 \% employees rated trips")
	page.find('.modal-body').find('#stats-fleet-idleness').find('p.lead').text.should eq('Under Expectation')
	page.find('.modal-body').find('#stats-fleet-idleness').find('div.easyPieChart').find('span').text.should eq("0\%")
	page.find('.modal-header').find('button.close').click
end