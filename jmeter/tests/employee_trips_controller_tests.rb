require_relative '../support/jmeter_helper'

test do
	threads count: threads_count, loop: loop_count, rampup: rampup_time do
		cookies policy: 'rfc2109'
		header [{name: 'Content-Type', value: 'application/json'}]
		# Authentication
	  	post name: 'Authenticate', url: host_url + '/users/sign_in', raw_body: "{\"user\": {\"username\": \"#{get_employer.user.email}\", \"password\": \"password\"}}"
	  	employee = get_employee_with_employee_trips
	  	user = employee.try(:user)
	  	user_name = user.f_name + " " + user.l_name rescue "Test Name"
	  	visit name: 'Employees Trips', url: host_url + '/employee_trips.json', raw_body: "{\"search\": \"#{user_name}\", \"startDate\": \"#{1.month.ago.strftime('%d/%m/%Y %l:%M %p')}\", \"endDate\": \"#{1.month.from_now.strftime('%d/%m/%Y %l:%M %p')}\"}"
	  	visit name: 'Clusters', url: host_url + '/employee_trips/get_clusters.json', raw_body: "{\"sEcho\": \"1\", \"search\": \"#{user_name}\", \"startDate\": \"#{1.month.ago.strftime('%d/%m/%Y %l:%M %p')}\", \"endDate\": \"#{1.month.from_now.strftime('%d/%m/%Y %l:%M %p')}\"}"

	  	visit name: 'Employee Trips', url: host_url + "/employees/#{employee.id}/trips.json", raw_body: "{\"range_from\": \"#{1.month.ago.strftime('%d/%m/%Y %l:%M %p')}\", \"range_to\": \"#{1.month.from_now.strftime('%d/%m/%Y %l:%M %p')}\"}"
	end
end.run(
	file: 'jmeter/jmx_files/employee_trips_controller_tests.jmx',
	jtl: 'jmeter/results/employee_trips_controller_results.jtl',
	log: 'jmeter/logs/employee_trips_controller_logs.log'
	)