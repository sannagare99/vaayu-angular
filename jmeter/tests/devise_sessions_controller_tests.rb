require_relative '../support/jmeter_helper'

test do
	threads count: threads_count, loop: loop_count, rampup: rampup_time do
		visit name: 'User Log In Page', url: host_url
	end
end.run(
	file: 'jmeter/jmx_files/devise_session_controller_tests.jmx',
	jtl: 'jmeter/results/devise_session_controller_results.jtl',
	log: 'jmeter/logs/devise_session_controller_logs.log'
	)