@javascript
Feature: Testing Assigning Driver to Trips with Female Employee in odd times by Employer Login 

  @EMR.UC5.US4
  Scenario: Employer views all Manifests with female exception
  	Given Filling database and login as admin using cookies
	Given I create "0" male employees and "1" female employees in database
	Given I create guard in database
	When I create new shift with check_in "02:00" and check_out "04:00"
	Then I create trip for employee -"2" for "Today"
	Given I am on "/trips"
	Given I click link "Manifest"
	Then I should see alert sign for trip -"1"

  @EMR.UC5.US5
  Scenario: Employer views a selected Manifest with a female exception
	Given Filling database and login as admin using cookies
	Given I create "0" male employees and "1" female employees in database
	Given I create guard in database
	When I create new shift with check_in "02:00" and check_out "04:00"
	Then I create trip for employee -"2" for "Today"
	Given I am on "/trips"
	Given I click link "Manifest"
	Then I should see alert sign for trip -"1"
	When I open the employee trip Manifest -"1"
	Then I should see "Add Guard"

  @EMR.UC5.US6
  Scenario: Employer views a list of available Security Guards
	Given Filling database and login as admin using cookies
	Given I create "0" male employees and "1" female employees in database
	Given I create guard in database
	When I create new shift with check_in "02:00" and check_out "04:00"
	Then I create trip for employee -"2" for "Today"
	Given I am on "/trips"
	Given I click link "Manifest"
	When I open the employee trip Manifest -"1"
	Given I click link "Add Guard" 
	Then should see name of Guard -"1"

  @EMR.UC5.US7 @Regression @Issue.543 @Issue.554 @Issue.761
  Scenario: Employer views a list of available Security Guards
	Given Filling database and login as admin using cookies
	Given I create "0" male employees and "1" female employees in database
	Given I create guard in database
	When I create new shift with check_in "02:00" and check_out "04:00"
	Then I create trip for employee -"2" for "Today"
	Given I am on "/trips"
	Given I click link "Manifest"
	When I open the employee trip Manifest -"1"
	Given I click link "Add Guard" 
	Then should see name of Guard -"1"
	Given I select guard - "1"
	When I open the employee trip Manifest -"1"
	Then should see name of Guard -"1"

  @EMR.UC5.US8
  Scenario: [BUG]Employer can edit the assigned Security Guard
	Given Filling database and login as admin using cookies
	Given I create "0" male employees and "1" female employees in database
	Given I create guard in database
	When I create new shift with check_in "02:00" and check_out "04:00"
	Then I create trip for employee -"2" for "Today"
	Given I am on "/trips"
	Given I click link "Manifest"
	When I open the employee trip Manifest -"1"
	Given I click link "Add Guard" 
	Then should see name of Guard -"1"
	Given I select guard - "1"
	When I open the employee trip Manifest -"1"
	Given I delete assigned guard
	# Then I should not see guard assigned
	# Then I should see "Add Guard"
	# Given I click link "Add Guard" 
	# Then should see name of Guard -"1"
	# Given I select guard - "1"
	# When I open the employee trip Manifest -"1"
	# Then should see name of Guard -"1"

  @EMR.UC5.US9
  Scenario: [BUG]Employer can auto-assign multiple Security Guards
	Given Filling database and login as admin using cookies
	Given I create "0" male employees and "2" female employees in database
	Given I create guard in database
	Given I create guard in database
	When I create new shift with check_in "02:00" and check_out "04:00"
	Then I create trip for employee -"2" for "Today"
	Then I create trip for employee -"3" for "Today"
	Given I am on "/trips"
	Given I click link "Manifest"
	Then I should see alert sign for trip -"1"
	Then I should see alert sign for trip -"2"
	When Buttons "Auto Assign Guard" pressed
	When I open the employee trip Manifest -"1"
	# Then I should see guard assigned
	When Buttons "×" pressed
	When I open the employee trip Manifest -"2"
	# Then I should see guard assigned
	