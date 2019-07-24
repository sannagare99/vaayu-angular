require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given(/^Create Trip roster with 2 employees - male and female$/) do
  step 'Create Trip roster with 1 employee - male'
  step 'Create Trip roster with 1 employee - female'
end

Given(/^Create Trip roster with 1 employee - female$/) do
  @female_trip_time = Time.now.end_of_day - 1.hour
  step 'Create EmployeeTrip for female employee'
  step 'Create a trip for female employee'
end

Given(/^Create Trip roster with 1 employee - male$/) do
  @male_trip_time = Time.now + 2.hour
  step 'Create EmployeeTrip for male employee'
  step 'Create a trip for male employee'
end


Given(/^Create a trip for male employee$/) do
  @male_trip = Trip.create(site_id: @site.id, trip_type: 0, status: 'created', employee_trip_ids: [@male_employee_trip.id])
end

Given(/^Create a trip for female employee$/) do
  @female_trip = Trip.create(site_id: @site.id, trip_type: 0, status: 'created', employee_trip_ids: [@female_employee_trip.id])
end

Given(/^Create EmployeeTrip for male employee$/) do
  @male_employee_trip = EmployeeTrip.create(site_id: @site.id, employee_id: @male_employee.id, trip_type: 0, status: 'trip_created', state: 0, schedule_date: @male_trip_time, bus_rider: false, date: @male_trip_time)
end

Given(/^Create EmployeeTrip for female employee$/) do
  @female_employee_trip = EmployeeTrip.create(site_id: @site.id, employee_id: @female_employee.id, trip_type: 0, status: 'trip_created', state: 0, schedule_date: @female_trip_time, bus_rider: false, date: @female_trip_time)
end

Given(/^Create TripRoute for male employee$/) do
  @male_trip_route = TripRoute.create(planned_duration: 21, planned_distance: 8238, planned_route_order: 0, planned_start_location: {:lat => 28.4516511, :lng => 77.0831306}, planned_end_location: {:lat => 28.4941074,  :lng => 77.0893377 }, employee_trip_id: @male_employee_trip.id, trip_id: @male_trip.id, status: 'not_started', scheduled_distance: 8238, scheduled_duration: 21, scheduled_route_order: 0 ,scheduled_start_location: {:lat => 28.4516511, :lng => 77.0831306}, scheduled_end_location: {:lat => 28.4941074,  :lng => 77.0893377 }, bus_stop_name: '', bus_stop_address: '')
end

Given(/^Create TripRoute for female employee$/) do
  @female_trip_route = TripRoute.create(planned_duration: 21, planned_distance: 8238, planned_route_order: 0, planned_start_location: {:lat => 28.4516511, :lng => 77.0831306}, planned_end_location: {:lat => 28.4941074,  :lng => 77.0893377 }, employee_trip_id: @female_employee_trip.id, trip_id: @female_trip.id, status: 'not_started', scheduled_distance: 8238, scheduled_duration: 21, scheduled_route_order: 0 ,scheduled_start_location: {:lat => 28.4516511, :lng => 77.0831306}, scheduled_end_location: {:lat => 28.4941074,  :lng => 77.0893377 }, bus_stop_name: '', bus_stop_address: '')
end