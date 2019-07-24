require File.expand_path(File.join(File.dirname(__FILE__), "../../", "support", "paths"))

def selected_date_scheduler
  '.calendar-schedule-section tbody .green-background .schedule-column'
end

# Shift Creation
def setup_new_shift duplicate_field
  # get fake shift data for new employee
  @shift_data = {}
  @shift_data['check_in'] = Faker::Time.between(0.days.ago, Date.today, :morning).to_s[11,12]
  @shift_data['check_out'] = Faker::Time.between(0.days.ago, Date.today, :afternoon).to_s[11,12]
  @shift_data['time_display'] = @shift_data['check_in']+':'+@shift_data['check_out']
  # puts @shift_data
end

# Shift Creation
def time_generator gap,time
  gap = - gap
  case time
  when 'Morning'
    Faker::Time.between(gap.to_i.days.ago, Date.today, :morning)
  when 'Afternoon'
    Faker::Time.between(gap.to_i.days.ago, Date.today, :afternoon)
  when 'Evening'
    Faker::Time.between(gap.to_i.days.ago, Date.today, :evening)
  when 'Midnight'
    Faker::Time.between(gap.to_i.days.ago, Date.today, :midnight)
  when 'Day'
    Faker::Time.between(gap.to_i.days.ago, Date.today, :day)
  when 'Night'
    Faker::Time.between(gap.to_i.days.ago, Date.today, :night)
  when 'All'
    Faker::Time.between(gap.to_i.days.ago, Date.today, :all)
  when /^([0-9][0-9]) Mins/
    Time.now+$1.to_i.minutes
  when /^([0-9][0-9]) Hours/
    Time.now+$1.to_i.hours
  else
    Faker::Time.between(gap.to_i.days.ago, Date.today, :all)
  end
end

def create_new_shift(gap,employee_id,check_in,check_out)
  # get fake shift data for new employee
  @shift_data = {}
  gap=0 if !gap
  gap = - gap
  check_in = Faker::Time.between(gap.to_i.days.ago, Date.today, :morning).to_datetime if !check_in
  check_in = check_in + rand(15).minutes if check_in
  @shift_data['check_in'] = check_in
  # puts check_in
  check_out = Faker::Time.between(gap.to_i.days.ago, Date.today, :afternoon).to_datetime if !check_out
  check_out = check_out + rand(15).minutes if check_out
  @shift_data['check_out'] = check_out
  # puts check_out
  @shift_data['time_display'] = @shift_data['check_in'].to_s[11..15]+':'+@shift_data['check_out'].to_s[11..15]
  # puts @shift_data['time_display']
  schedule_date = Time.zone.parse("#{check_in.to_s[0..9]} 04:30:00")
  # puts schedule_date
  EmployeeTrip.create( employee_id: employee_id, site_id: 1, date: check_in, trip_type: 0, status: 'upcoming',state: 0, schedule_date: schedule_date)
  EmployeeTrip.create( employee_id: employee_id, site_id: 1, date: check_out, trip_type: 1, status: 'upcoming',state: 0, schedule_date: schedule_date)
end

def fill_shift_data *remove_fields
  # Select Site 
  page.find('.employee_check_in_check_in').first('input').set(@shift_data['check_in']) if (!remove_fields.include?  'Check In')
  sleep(2) 
  page.find('.employee_check_out_check_out').first('input').set(@shift_data['check_out']) if (!remove_fields.include?  'Check Out')
  sleep(2)
  page.find('.employee_check_out_site_id').find('select').find(:xpath, 'option[2]').select_option if (!remove_fields.include?  'Check Out')
  sleep(2)
end

When(/^I click on selected date in Calendar Schedule Section$/) do
  # puts page.find(selected_date_scheduler)
  page.find(selected_date_scheduler).first('p').click
end

When(/^I should see "([^"]*)" in "([^"]*)" section in Calendar Schedule Section$/) do |text, day|
  page.find(selected_date_scheduler).has_content?(text).should be true
end

Given(/^Fill form new shift data in "([^"]*)" section$/) do |arg1|
  setup_new_shift ''
  fill_shift_data ''
end

When(/^Save shift form data$/) do
  # find_button('Save changes').click
  page.find('.modal-footer .btn-primary').click
end

Then(/^I should see correct shift data in "([^"]*)" section$/) do |arg1|
  page.find(selected_date_scheduler).has_content?(@shift_data['time_display']).should be true
end

When(/^I create schedule data for "([^"]*)" for "([^"]*)" Employee$/) do |day, count|
  gap = 0 if day=="Today"
  gap = 1 if day=="Tomorrow"
  Employee.last(count).each do |employee|
    # puts employee.user.to_json
    # puts employee.to_json
    create_new_shift(gap,employee.id, nil, nil)
  end
end

When(/^I create schedule data for "([^"]*)" for "([^"]*)" Employee with check_in in "([^"]*)" and check_out in "([^"]*)"$/) do |day, count,in_time,out_time|
  gap = 0 if day=="Today"
  gap = 1 if day=="Tomorrow"
  # puts gap
  check_in = time_generator(gap,in_time)
  check_out = time_generator(gap,out_time)
  Employee.last(count).each do |employee|
    # puts employee.user.to_json
    # puts employee.to_json
    create_new_shift(gap,employee.id, check_in, check_out)
  end
end

When(/^I create shift for Shift Provisioning$/) do
  create_shift('10:00', '14:00')
end

When(/^I create 2 shifts for Shift Provisioning$/) do
  create_shift('10:00', '14:00')
  create_shift('11:00', '15:00')
end

When(/^Open Select Shift dropdown$/) do
  page.find('.multiselect-selected-text').click
  sleep(1)
  page.all('.multiselect-all')[0].click
end

When(/^I select "([^"]*)" shift for check in$/) do |index|
  shift = Shift.find(index.to_i)
  selected = page.find('.employee-schedule-table .green-background')
  selected.find('.check_in').click
  selected.find('.employee_check_in_shift_id .check_in_shift_select').find(:option, shift.start_time).select_option
end

When(/^I select "([^"]*)" shift for check out$/) do |index|
  shift = Shift.find(index.to_i)
  selected = page.find('.employee-schedule-table .green-background')
  selected.find('.employee_check_out_shift_id .check_out_shift_select').find(:option, shift.end_time).select_option
end

When(/^I select location for shift$/) do
  selected = page.find('.employee-schedule-table .green-background')
  selected.find('.check_out_location_select').find(:xpath, 'option[2]').select_option
end

When(/^I should see Shift timings "([^"]*)"$/) do |index|
  shift = Shift.find(index.to_i)
  page.has_content?(shift.start_time+':'+shift.end_time).should be true
end

When(/^I save selected shifts$/) do
  page.find('.modal-footer').find('.btn-primary').click
end

When(/^I click on Edit Shifts of employer shift manager$/) do
  page.find('#employer-shift-managers-table tbody tr td:nth-child(4)').find('a').click
end

When(/^I select "([^"]*)" shift for check in of employer shift manager$/) do |index|
  shift = Shift.find(index.to_i)
  selected = page.find('.employee-schedule-table .green-background')
  selected.find('.check_in').click
  selected.find('.employer_shift_manager_check_in_check_in input').set(shift.start_time)
end

When(/^I select "([^"]*)" shift for check out of employer shift manager$/) do |index|
  shift = Shift.find(index.to_i)
  selected = page.find('.employee-schedule-table .green-background')
  selected.find('.employer_shift_manager_check_out_check_out input').set(shift.end_time)
end

When(/^I select location for shift of employer shift manager$/) do
  selected = page.find('.employee-schedule-table .green-background')
  selected.find('.employer_shift_manager_check_out_site_id .check_out_location_select').find(:xpath, 'option[2]').select_option
end

When(/^I should see Shift timings "([^"]*)" for employer shift manager$/) do |index|
  shift = Shift.find(index.to_i)
  selected = page.find('.employee-schedule-table .green-background')
  selected.find('.check_in').click
  selected.find('.employer_shift_manager_check_in_check_in input').value.should eq shift.start_time
  selected.find('.employer_shift_manager_check_out_check_out input').value.should eq shift.end_time
end

When(/^I submit employee form$/) do
  page.find('#form-employees').find('.btn-primary').first.click
  sleep(4)
end

Given(/^Get Cookies$/) do
  if !@session_cookie
    @session_cookie = page.driver.browser.manage.cookie_named('_moove_session')[:value]
  else
    page.driver.browser.manage.delete_all_cookies
    page.driver.browser.manage.add_cookie(:name => "_moove_session", :value => @session_cookie,
      :path=>"/", :domain=>"127.0.0.1", :expires=>nil, :secure=>false)
  end
end

When(/^I should see error in schedule input$/) do
  page.all('.error-input-color').count > 0
end
