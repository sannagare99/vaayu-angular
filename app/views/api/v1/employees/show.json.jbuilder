json.extract! @employee, :user_id, :username, :email, :f_name, :m_name, :l_name, :phone, :employee_id, :home_address
json.profile_picture @employee.full_avatar_url

json.emergency_contact do
  json.name @employee.emergency_contact_name
  json.phone @employee.emergency_contact_phone
end

json.employer do
  json.name @employee.employer_name
  json.phone @employee.employer_phone
end

json.schedule @employee.employee_schedules.complete do |employee_schedule|
  json.day employee_schedule.day_number
  json.check_in employee_schedule.check_in.to_i
  json.check_out employee_schedule.check_out.to_i
end

json.shift_check_in @employee_shifts  do |shift|
	json.start_time shift.start_time
end

json.shift_check_out @employee_shifts  do |shift|
	json.end_time shift.end_time
end

json.site do
  json.name [@employee.site.name]
end