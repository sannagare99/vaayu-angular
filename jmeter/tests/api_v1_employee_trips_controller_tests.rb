require_relative '../support/jmeter_helper'

test do
	threads count: threads_count, loop: loop_count, rampup: rampup_time do
		employee = get_employee_with_employee_trips
		employee_trip = employee.try(:employee_trips).try(:last)
		cookies policy: 'rfc2109'
		header employee.user.create_new_auth_token.merge({'Content-Type' => 'application/json'}).map{|k, v| {name: k, value: v}}
	  	visit name: 'EmployeeTrips', url: host_url + "/api/v1/employee_trips/#{employee_trip.id}.json"
	end
end.run(
	file: 'jmeter/jmx_files/api_v1_employee_trips_controller_tests.jmx',
	jtl: 'jmeter/results/api_v1_employee_trips_controller_results.jtl',
	log: 'jmeter/logs/api_v1_employee_trips_controller_logs.log'
	)