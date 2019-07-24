require File.expand_path(File.join(File.dirname(__FILE__), "../../", "support", "paths"))

def create_shift(check_in, check_out)
	@shift = FactoryGirl.create(:shift, start_time: check_in, end_time: check_out)
end

def create_employee_trip(shift,employee,date,direction)
	if direction == "check_in"
		shift_time = shift.start_time
		@updated = Time.parse(date.to_s[0..9]+" "+shift_time+Time.now.to_s[16..-1])
		@schedule_date = Time.parse(date.to_s[0..9]+" "+"10:00"+Time.now.to_s[16..-1])
		@check_in_date = @updated.utc
		@employee_trip = FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_in, date: @updated,schedule_date: @schedule_date, bus_rider: false)
	else
		shift_time = shift.end_time
		@updated = Time.parse(date.to_s[0..9]+" "+shift_time+Time.now.to_s[16..-1])
		@schedule_date = Time.parse(date.to_s[0..9]+" "+"10:00"+Time.now.to_s[16..-1])
		@check_out_date = @updated
		@employee_trip = FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_out, date: @updated,schedule_date: @schedule_date, bus_rider: false)
	end
	
end

def create_trip(id)
	@trip = Trip.new(:employee_trip_ids_with_prefix=>[id.to_s])
  @trip.site = @trip.employee_trips.first.employee.site
  @trip.bus_rider = @trip.employee_trips.first.bus_rider
  @trip.save!
end

def create_all_trips(id,date,direction)
  case date
  when 'Today'
    @date = Date.today
  when 'Tomorrow'
    @date = Date.tomorrow
  else
    @date = Date.today
  end
  @employee = Employee.find(id)
  @employee_trip = create_employee_trip(@shift,@employee,@date,direction)
  create_trip(@employee_trip.id)
end

Given(/^Filling database and login as admin using cookies$/) do
  step 'Filling database'
  step 'I create admin in database'
  if !@session_cookie
    step 'I am on "/"'
    step 'I am try to log in as admin'
  end
  step 'Get Cookies'
end

Given(/^I create admin in database$/) do
  @admin = User.create! email:'marina.derkach@n3wnormal.com', username: 'marina', password:'n3wnormal', role: 4, f_name: 'Marina', l_name: 'Derkach', phone: '6666666'
end

Given(/^I create guard in database$/) do
  @guard = FactoryGirl.create(:employee, site: @site, employee_company: @employee_company, is_guard: 1)
  puts @guard.f_name
  @guard
end

When(/^I am try to log in as admin/) do
  sleep(1)
  page.find("#user_username").set(@admin.email)
  sleep(1)
  page.find("#user_password").set('n3wnormal')
  sleep(1)
  page.find('.btn-primary').click
end

When(/^I create new shift with check_in "([^"]*)" and check_out "([^"]*)"$/) do |check_in, check_out|
  	@shift = create_shift(check_in, check_out)
end

Then(/^I create trip for employee \-"([^"]*)" for "([^"]*)"$/) do |id,date|
  create_all_trips(id,date,"check_in")
end

Then(/^I create "([^"]*)" trip for employee \-"([^"]*)" for "([^"]*)"$/) do |direction,id,date|
  create_all_trips(id,date,direction)
end

Then(/^I should see alert sign for trip \-"([^"]*)"$/) do |id|
  page.find("#operator-assigned-trips-table tr:nth-child(#{id}) td:nth-child(1)").should have_css('i.fa.fa-exclamation-circle.fa-lg')
end
When(/^I open the employee trip Manifest \-"([^"]*)"$/) do |id|
  page.find("#operator-assigned-trips-table tr:nth-child(#{id}) td:nth-child(1) a").click
  # step "Wait for modal \"Trip Roster # #{@updated.utc.strftime('%Y/%m/%d')} - #{@trip.id}\""
end

Then(/^should see name of Guard \-"([^"]*)"$/) do |id|
  guard = Employee.where(is_guard: true)[id.to_i-1]
  name = guard.f_name + " " + guard.l_name
  # page.find("#guards-list-table tbody tr:nth-child(#{id}) td:nth-child(1)").text.should eq name
  step("I should see \"#{name}\"")
end

Given(/^I select guard \- "([^"]*)"$/) do |id|
  page.find("#guards-list-table tbody tr:nth-child(#{id}) .guard_employee_id").click
  page.find('#add-guard-to-trip').click #click on assign driver
  sleep(1)
end

Given(/^I delete assigned guard$/) do
  page.all("#guards-list-table tbody tr").each do |tr|
  	if tr.find("td:nth-child(2)").text == "Driver"
  		tr.find("td:nth-child(7)").click
  	end
  end
  sleep(1)
end

Then(/^I should not see guard assigned$/) do
	page.find("#operator-unassigned-roster-table tbody").has_content?("Guard").should be false
end

Then(/^I should see guard assigned$/) do
	page.find("#operator-unassigned-roster-table tbody").has_content?("Guard").should be true
end

Then(/^I should see "([^"]*)" Manifests$/) do |count|
	if count == "Multiple"
		page.all("#operator-assigned-trips-table tbody tr").count.should > 0
	else
		page.all("#operator-assigned-trips-table tbody tr").count.should eq count.to_i
	end
end

Then(/^I should see all details of Manifest No. "([^"]*)"/) do |id|
	tr = page.find("#operator-assigned-trips-table tbody tr:nth-child(1)")
	if tr.find("td:nth-child(4)").has_content?("Check in")
		date = @check_in_date
		tr.find("td:nth-child(3)").has_content?(@shift.start_time).should be true
	else
		date = @check_out_date
		tr.find("td:nth-child(3)").has_content?(@shift.end_time).should be true
	end
	tr.find("td:nth-child(1)").has_content?(date.strftime('%m/%d/%Y')).should be true
	tr.find("td:nth-child(2)").has_content?(date.strftime('%m/%d/%Y')).should be true
	tr.find("td:nth-child(6)").text.should eq "1"
end

Given(/^Change manifest direction to "([^"]*)"$/) do |direction|
  page.find('#manifest-trip-directionSelectBoxIt').click
  sleep(2)
  val = direction == 'check_in' ? '0' : '1'
  page.find('#manifest-trip-directionSelectBoxItOptions').find('li[data-val="' + val + '"]').click
  sleep(1)
end
