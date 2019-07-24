require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then(/^I should see created trip manifests ordered by time$/) do
  page.find('#operator-assigned-trips-table tr:nth-child(1) td:nth-child(3)').text.should eq @female_trip_time.strftime("%I:%M%p")
  page.find('#operator-assigned-trips-table tr:nth-child(2) td:nth-child(3)').text.should eq @male_trip_time.strftime("%I:%M%p")
  @manifest_to_delete = page.find('#operator-assigned-trips-table tr:nth-child(1) td:nth-child(1)').text
  @manifest_to_keep = page.find('#operator-assigned-trips-table tr:nth-child(2) td:nth-child(1)').text
end

Then(/^I should see alert sign for female trips$/) do
  page.find('#operator-assigned-trips-table tr:nth-child(1) td:nth-child(1)').should have_css('i.fa.fa-exclamation-circle.fa-lg')
end

When(/^I delete a manifest$/) do
  page.find('#operator-assigned-trips-table tr:nth-child(1) td:nth-child(1) a').click
  step "Wait for modal \"Trip Roster # #{@female_trip_time.strftime('%Y/%m/%d')} - #{@female_trip.id}\""
  page.find('#delete-roster').click
  sleep(2)
end

Then(/^I should not see deleted manifest$/) do
  page.find('#operator-assigned-trips-table tr:nth-child(1) td:nth-child(1)').text.should eq @manifest_to_keep
  page.all('table#operator-assigned-trips-table tr').count.should eq 2
end

When(/^I open the female employee trip Manifest$/) do
  page.find('#operator-assigned-trips-table tr:nth-child(1) td:nth-child(1) a').click
  step "Wait for modal \"Trip Roster # #{@female_trip_time.strftime('%Y/%m/%d')} - #{@female_trip.id}\""
end

When(/^I open the male employee trip Manifest$/) do
  page.find('#operator-assigned-trips-table tr:nth-child(1) td:nth-child(1) a').click
  step "Wait for modal \"Trip Roster # #{@male_trip_time.strftime('%Y/%m/%d')} - #{@male_trip.id}\""
end

When(/^I open the male employee driver assigned trip Manifest$/) do
  page.find('#operator-assigned-trips-table tr:nth-child(1) td:nth-child(1) a').click
  step "Wait for modal \"#{@male_trip_time.strftime('%Y %m %d')} - #{@male_trip.id} (To Work)\""
end

Then(/^I should see correct Manifest information$/) do
  page.find('.modal').find('#operator-unassigned-roster-table tr:nth-child(1) td:nth-child(1)').text.should eq @female_employee.user.f_name + " " + @female_employee.user.l_name
  page.find('.modal').find('#operator-unassigned-roster-table tr:nth-child(1) td:nth-child(2)').text.should eq @female_employee.is_guard? ? 'Guard' : 'Call Centre'
  page.find('.modal').find('#operator-unassigned-roster-table tr:nth-child(1) td:nth-child(3)').text.should eq @female_employee.gender.to_s.first.capitalize
  page.find('.modal').find('#operator-unassigned-roster-table tr:nth-child(1) td:nth-child(4)').text.should eq @female_employee.home_address
  page.find('.modal').find('#operator-unassigned-roster-table tr:nth-child(1) td:nth-child(5)').text.should eq @female_employee_trip.planned_eta.localtime.strftime("%I:%M%p")
  page.find('.modal').find('#operator-unassigned-roster-table tr:nth-child(1) td:nth-child(6)').text.should eq @female_employee_trip.date.localtime.strftime("%H:%M")
end

Then(/^I should see appropriate actions in unassigned manifest normal trip$/) do
  page.find('.modal').should have_css('a#assign-trip-roster-modal')
end

Then(/^I should see appropriate actions in unassigned manifest alerted trip$/) do
  page.find('.modal').should have_css('a#assing-guard')
end

Then(/^I try to see available drivers for first manifest$/) do
  page.find('#operator-assigned-trips-table tr:nth-child(1) td:nth-child(7) #assign_driver').click
  page.find('#available-drivers').click
end

Then(/^I should see listed details of available drivers$/) do
  page.find('.modal').find('#assign-driver-table tr:nth-child(1) td:nth-child(1)').text.should eq @driver.vehicle.plate_number
  page.find('.modal').find('#assign-driver-table tr:nth-child(1) td:nth-child(2)').text.should eq @driver.user.f_name + " " + @driver.user.l_name
  page.find('.modal').find('#assign-driver-table tr:nth-child(1) td:nth-child(6)').text.should eq @driver.status
end

When(/^I assign the driver to given manifest$/) do
  page.find(:xpath, "//label[@for='available-drivers-r-1']").click
  page.find('#assign-roster-confirm').click #click on assign driver
  sleep(1)
  page.find('#assign-driver-submit').click
  sleep(1)
end

Then(/^I should be able to see the assigned driver$/) do
  page.find('#operator-assigned-trips-table tr:nth-child(1) td:nth-child(5)').text.should eq @driver.user.f_name + " " + @driver.user.l_name + " (Pending)"
end

When(/^I Open map$/) do
  page.find('#open-map').click
end

Then(/^I can see the trip map$/) do
  page.find('.modal').should have_css('div#map-trip-info')
end