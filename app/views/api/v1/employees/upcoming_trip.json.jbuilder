if @employee_trip
  json.partial! 'api/v1/employee_trips/employee_trip', locals: { employee_trip: @employee_trip, employee: @employee }
end

json.site do
  json.name [@employee.site.name]
end

json.shift_check_in @employee_shifts  do |shift|
	json.start_time shift.start_time
end

json.shift_check_out @employee_shifts  do |shift|
	json.end_time shift.end_time
end

json.change_time_check_in @change_time_check_in
json.change_time_check_out @change_time_check_out
json.cancel_time_check_in @cancel_time_check_in
json.cancel_time_check_out @cancel_time_check_out
json.consider_non_compliant_cancel_as_no_show @consider_non_compliant_cancel_as_no_show
json.change_request_require_approval @change_request_require_approval
