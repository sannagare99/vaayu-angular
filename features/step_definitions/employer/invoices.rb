require File.expand_path(File.join(File.dirname(__FILE__), "../..", "support", "paths"))

Given(/^I create data for daily macro parameters in the employer billing$/) do
  step 'Create operator for the employer billing'
  step 'Create site for employer billing'
  step 'Create employees for employer billing'
  step 'Create vehicle for employer billing'
  step 'Create driver for employer billing'
  step 'Create daily employee trips for employer billing'
  step 'Create daily trips for employer billing'
  step 'Complete daily trip with exception'
end

Given(/^Create operator for the employer billing$/) do
  @operator = FactoryGirl.create(:operator, logistics_company: @logistics_company)
end

Given(/^Create site for employer billing$/) do
  address = 'Shubham Complex, Opposite ESIS Hospital, Akurli Road, Akurli Industry Estate, Kandivali East, Mumbai, Maharashtra 400101, India'
  @site = FactoryGirl.create(:site, employee_company: @employee_company, address: address, latitude: 19.2013359, longitude: 72.855722)
end


Given(/^Create employees for employer billing$/) do
  address_1 = '2nd Floor, Kenilworth Mall, Phase 2, Off Linking Road, Behind KFC, Bandra West, Bandra West, Mumbai, Maharashtra 400050, India'
  id_1 = 'ID233E3'
  @employee_1 = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company, employee_id: id_1, home_address: address_1)
end

Given(/^Create vehicle for employer billing$/) do
  device_id_1 = 'd001'
  plate_number_1 = 'MH12301'
  @vehicle_1 = FactoryGirl.create(:vehicle, plate_number: plate_number_1, device_id: device_id_1)
end

Given(/^Create driver for employer billing$/) do
  address_1 = 'Shop No. 4, Mishra House, Khar West, Chitrakar Dhurandhar Road, Ram Krishna Nagar, Ram Krishna Nagar, Khar West, Mumbai, Maharashtra 400052, India'
  badge_number_1 = 'ABC'
  aadhaar_number_1 = '123'
  licence_number_1 = 'ABCDEFGHIJ12345'
  @driver_1 = FactoryGirl.create(:driver, site: @site, logistics_company: @logistics_company, permanent_address: address_1, local_address: address_1, badge_number: badge_number_1, aadhaar_number: aadhaar_number_1, licence_number: licence_number_1, vehicle: @vehicle_1)
  @auth_token_driver = @driver_1.user.create_new_auth_token
end

Given(/^Create daily employee trips for employer billing$/) do
  @trip_time_1 = Time.now - 1.hour
  @employee_trip_1 = EmployeeTrip.create(site_id: @site.id, employee_id: @employee_1.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: @trip_time_1, bus_rider: false, date: @trip_time_1, rating: 4)
end

Given(/^Create daily trips for employer billing$/) do
  @trip = Trip.create(site_id: @site.id, trip_type: 0, status: 'active', employee_trip_ids: [@employee_trip_1.id], driver: @driver_1, vehicle: @vehicle_1, start_date: @trip_time_1 - 15.minutes)
  @employee_trip_1.update(trip_id: @trip.id, trip_route_id: @trip.trip_routes.first.id)
end

Given(/^Complete daily trip with exception$/) do
  @trip.cancel_complete_trip
  @trip.update(:cancel_status => 'Driver Completed Trip')
end

When(/^I generate invoice of daily trip$/) do
  page.find("#billing-completed-trips-table tbody tr:nth-child(1) .checkbox-select").click
  page.find("#generate-invoices").click
end

When(/^I select invoice of daily trip$/) do
  page.find("#customer-invoices-table tbody tr:nth-child(1) .checkbox-select").click
end

When(/^I download invoice of daily trip$/) do
  page.find("#download-invoices").click
end

When(/^I generate invoice of daily trip in database$/) do
  @invoice = Invoice.create(company_type:'EmployeeCompany', company_id: @employee_company.id, date: Time.now, start_date: Time.now - 2.days, end_date: Time.now, trips_count: 1, amount: 0, status: :created)
  @trip.update(toll: 0, penalty: 0, amount: 0, paid: 1)
  TripInvoice.create(trip: @trip, invoice: @invoice)
end

When(/^I view generated invoice$/) do
  page.find("#customer-invoices-table tbody tr:nth-child(1) #open-invoice-modal").click
end

Then(/^I should see invoice generated for the daily trip$/) do
  page.all("#customer-invoices-table tbody tr").count.should eq 1
end

Then (/^I should see details of invoice generated$/) do
  row = page.find("#detail-info-trips-table tbody tr:nth-child(1)")
  # row.find("td:nth-child(1)").text.should eq "#{@trip_time_1.strftime('%m-%d-%Y')} - #{@trip.id}"
  row.find("td:nth-child(2)").text.should eq @employee_company.name
  row.find("td:nth-child(3)").text.should eq @trip.vehicle.model
  row.find("td:nth-child(5)").text.to_i.should eq @trip.toll
  row.find("td:nth-child(6)").text.to_i.should eq @trip.penalty
  row.find("td:nth-child(8)").text.to_i.should eq @invoice.trips_count
  row.find("td:nth-child(9)").text.to_i.should eq @invoice.amount
end

When(/^I open status of generated invoice$/) do
  page.find("#customer-invoices-table tbody tr:nth-child(1) #open-status-modal").click
end

Then(/^I see status of invoice as "([^"]*)"$/) do |status|
  page.find("#customer-invoices-table tbody tr:nth-child(1) td:nth-child(10)").text.should eq status
end

When(/^I set status of invoice as "([^"]*)"$/) do |status|
  case status
  when 'New'
    input = "#created_status"
  when 'Approved'
    input = "#approved_status"
  when 'Dirty'
    input = "#dirty_status"
  when 'Paid'
    input = "#paid_status"
  else
    input = "#created_status"
  end
  page.find(input).click
  page.find("#save_status").click
  sleep(2)
end