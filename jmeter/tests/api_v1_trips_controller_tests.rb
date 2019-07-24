require_relative '../support/jmeter_helper'

test do
	threads count: threads_count, loop: loop_count, rampup: rampup_time do
		cookies policy: 'rfc2109'
		trip = get_trip_with_assigned_driver
		if trip
			header trip.driver.user.create_new_auth_token.merge({'Content-Type' => 'application/json'}).map{|k, v| {name: k, value: v}}
	  		visit name: 'Show Trips', url: host_url + "/api/v1/trips/#{trip.id}"
	  		post name: 'Driver Arrived', url: host_url + "/api/v1/trips/#{trip.id}/trip_routes/driver_arrived.json"
	  		post name: 'Onboard', url: host_url + "/api/v1/trips/#{trip.id}/trip_routes/on_board.json"
	  	end
	end
end.run(
	file: 'jmeter/jmx_files/api_v1_trips_controller_tests.jmx',
	jtl: 'jmeter/results/api_v1_trips_controller_results.jtl',
	log: 'jmeter/logs/api_v1_trips_controller_logs.log'
	)