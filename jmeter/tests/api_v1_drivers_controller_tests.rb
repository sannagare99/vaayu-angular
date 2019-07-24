require_relative '../support/jmeter_helper'

test do
	threads count: threads_count, loop: loop_count, rampup: rampup_time do
		cookies policy: 'rfc2109'
		header get_driver.user.create_new_auth_token.merge({'Content-Type' => 'application/json'}).map{|k, v| {name: k, value: v}}
	  	post name: 'Heart Beat', url: host_url + "/api/v1/drivers/#{get_driver.user.id}/heart_beat", raw_body: "{\"lat\": \"19.2013359\", \"lng\": \"72.855722\"}"
	  	visit name: 'Upcoming Trip', url: host_url + "/api/v1/drivers/#{get_driver.user.id}/upcoming_trip"
	  	visit name: 'Show', url: host_url + "/api/v1/drivers/#{get_driver.user.id}"
	  	visit name: 'Last Trip', url: host_url + "/api/v1/drivers/#{get_driver.user.id}/last_trip_request"
	end
end.run(
	file: 'jmeter/jmx_files/api_v1_drivers_controller_tests.jmx',
	jtl: 'jmeter/results/api_v1_drivers_controller_results.jtl',
	log: 'jmeter/logs/api_v1_drivers_controller_logs.log'
	)