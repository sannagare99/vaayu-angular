require_relative '../support/jmeter_helper'

test do
	threads count: threads_count, loop: loop_count, rampup: rampup_time do
		cookies policy: 'rfc2109'
		trip = get_trip_with_assigned_driver
		if trip
			driver = trip.driver
			header driver.user.create_new_auth_token.merge({'Content-Type' => 'application/json'}).map{|k, v| {name: k, value: v}}
	  		post name: 'Update Current Location', url: host_url + "/api/v2/drivers/#{driver.user.id}/update_current_location", raw_body: "{\"values\": [{\"nameValuePairs\": {\"trip_id\": \"#{trip.id}\", \"lat\": \"19.2013359\", \"lng\": \"72.855722\"}}]}"
	  	end
	end
end.run(
	file: 'jmeter/jmx_files/api_v2_drivers_controller_tests.jmx',
	jtl: 'jmeter/results/api_v2_drivers_controller_results.jtl',
	log: 'jmeter/logs/api_v2_drivers_controller_logs.log'
	)