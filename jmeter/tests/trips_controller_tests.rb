require_relative '../support/jmeter_helper'

test do
	threads count: threads_count, loop: loop_count, rampup: rampup_time do
		cookies policy: 'rfc2109'
		header [{name: 'Content-Type', value: 'application/json'}]
		# Authentication
	  	post name: 'Authenticate', url: host_url + '/users/sign_in', raw_body: "{\"user\": {\"username\": \"#{get_operator.user.email}\", \"password\": \"password\"}}"
	  	visit name: 'Index Trips', url: host_url + '/trips'
	  	site = get_site_with_trips
	  	if site
	  		trip_id = site.trips.first.id
	  		# TODO: [BUG] TripsController#get_drivers:161 renders assign_driver but template is not there, uncomment below 2 lines when fixed
	  		# visit name: 'Get Driver', url: host_url + "/trips/#{trip_id}/get_drivers"
	  		# visit name: 'Employee Trips', url: host_url + "/trips/#{trip_id}/employee_trips"
	  	end
	  	visit name: 'Drivers Timeline', url: host_url + '/trips/drivers_timeline.json'

	end
end.run(
	file: 'jmeter/jmx_files/trips_controller_tests.jmx',
	jtl: 'jmeter/results/trips_controller_results.jtl',
	log: 'jmeter/logs/trips_controller_logs.log'
	)