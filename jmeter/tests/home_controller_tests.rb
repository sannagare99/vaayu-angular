require_relative '../support/jmeter_helper'

test do
	threads count: threads_count, loop: loop_count, rampup: rampup_time do
		cookies policy: 'rfc2109'
		header [{name: 'Content-Type', value: 'application/json'}]
		# Authentication
	  	post name: 'Authenticate', url: host_url + '/users/sign_in', raw_body: "{\"user\": {\"username\": \"#{get_operator.user.email}\", \"password\": \"password\"}}"
	  	# Homepage#index
	  	get name: 'Dashboard', url: host_url
	  	# Homepage#update_last_active_time
	  	post name: 'Update Last Active Time', url: host_url + '/update_last_active_time'
		# Homepage#badge_count
		get name: 'Badge Count', url: host_url + '/badge_count'
	end
end.run(
	file: 'jmeter/jmx_files/home_controller_tests.jmx',
	jtl: 'jmeter/results/home_controller_results.jtl',
	log: 'jmeter/logs/home_controller_logs.log'
	)