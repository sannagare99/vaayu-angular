@javascript
Feature: Testing Employee Trips Requests Management by Employer login under Manifest Tab 

  # Referencing step_definitions/employer/trip_guard.rb 
  @EMR.UC6.US1 @Regression @Issue.615
  Scenario: Employer views all Trip Manifests
    Given Filling database and login as admin using cookies
    Given I create "1" male employees and "1" female employees in database
    When I create new shift with check_in "02:00" and check_out "04:00"
    Then I create "check_in" trip for employee -"2" for "Today"
    Then I create "check_in" trip for employee -"3" for "Today"
    Given I am on "/trips"
    Given I click link "Manifest"
    Then I should see "Multiple" Manifests
    Then I should see "Assign Guard"
    Then I should see "Assign Driver"
    Then I should see "Complete With Exception"
    Then I should see all details of Manifest No. "1"

  @Issue.764 @Regression
  Scenario: Employer can open map of a selected Trip Manifest
    Given Filling database and login as employer using cookies
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee with check_in in "Morning" and check_out in "Evening"
    And Select Employee Trip Request "check_in" for "Today" fast
    Then I should see "1" Employee Trip Requests for "check_in"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    When I wait for "3" seconds
    Then I assign driver to last manifest
    When I click link "Manifest"
    When I open map of trip manifest
    Then I should see google map opened in trip manifest

  # Referencing step_definitions/employer/trip_guard.rb 
  @EMR.UC6.US2
  Scenario: [BUG]Employer can filter the Trip Manifests
    Given Filling database and login as admin using cookies
    Given I create "0" male employees and "1" female employees in database
    When I create new shift with check_in "02:00" and check_out "04:00"
    Then I create "check_in" trip for employee -"2" for "Today"
    Then I create "check_out" trip for employee -"2" for "Today"
    Given I am on "/trips"
    Given I click link "Manifest"
    Then I should see "2" Manifests
    Given Change manifest direction to "check_in"
    # Then I should see "1" Manifests
    # Given Change manifest direction to "check_out"
    # Then I should see "1" Manifests

  # Referencing step_definitions/employer/trip_guard.rb 
  @EMR.UC6.US3 @Regression @Issue.654 @Issue.746
  Scenario: Employer views filtered Trip Manifests
    Given Filling database and login as admin using cookies
    Given I create "0" male employees and "1" female employees in database
    When I create new shift with check_in "02:00" and check_out "02:30"
    Then I create "check_in" trip for employee -"2" for "Today"
    Then I create "check_out" trip for employee -"2" for "Today"
    Given I am on "/trips"
    Given I click link "Manifest"
    Then I should see "2" Manifests
    Given Change manifest direction to "check_in"
    Then I should see all details of Manifest No. "1"
    Given Change manifest direction to "check_out"
    Then I should see all details of Manifest No. "1"

  @EMR.UC6.US4
  Scenario: Employer can view the single Employees in a Trip Manifest
    Given Filling database and login as employer using cookies
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee with check_in in "Morning" and check_out in "Evening"
    And Select Employee Trip Request "check_in" for "Today" fast
    Then I should see "1" Employee Trip Requests for "check_in"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    When I click link "Manifest"
    When I click Manifest No. "1"
    Then I should see "Trip Roster #"
    Then I should check for "Process Code" for all employees in selected manifest for "check_in"
    Then I should check for "Sex" for all employees in selected manifest for "check_in"
    Then I should check for "ETA" for all employees in selected manifest for "check_in"
    Then I should check for "Shift Starts" for all employees in selected manifest for "check_in"

  @EMR.UC6.US4
  Scenario: Employer can view the multiple Employees in a Trip Manifest
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_in" for "Today" fast
    Then I should see "6" Employee Trip Requests for "check_in"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    When I click link "Manifest"
    When I click Manifest No. "1"
    Then I should see "Trip Roster #"
    Then I should check for "Process Code" for all employees in selected manifest for "check_in"
    Then I should check for "Sex" for all employees in selected manifest for "check_in"
    Then I should check for "ETA" for all employees in selected manifest for "check_in"
    Then I should check for "Shift Starts" for all employees in selected manifest for "check_in"

  @EMR.UC6.US4
  Scenario: Employer can view the multiple Employees in a Trip Manifest generated using Auto Cluster
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_in" for "Today" fast
    Then I should see "6" Employee Trip Requests for "check_in"
    When Buttons "Auto Cluster" pressed
    Then I should see "Multiple" Employee Trip Requests clusters
    When I deselect all Employee Trip Requests
    When I select Employee Trip Requests cluster "1"
    When Buttons "Create Trip Roster" pressed
    When I click link "Manifest"
    When I click Manifest No. "1"
    Then I should see "Trip Roster #"
    Then I should check for "Process Code" for all employees in selected manifest for "check_in"
    Then I should check for "Sex" for all employees in selected manifest for "check_in"
    Then I should check for "ETA" for all employees in selected manifest for "check_in"
    Then I should check for "Shift Starts" for all employees in selected manifest for "check_in"

  @EMR.UC6.US5
  Scenario: Employer can call an Employee of a selected Trip Manifest
    Given Filling database and login as employer using cookies
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee with check_in in "Morning" and check_out in "Evening"
    And Select Employee Trip Request "check_in" for "Today" fast
    Then I should see "1" Employee Trip Requests for "check_in"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    When I click link "Manifest"
    When I click Manifest No. "1"
    Then I should see "Trip Roster #"
    When I wait for "2" seconds
    When I call employee "1" on manifest
    When I wait for "2" seconds
    Then I should see "You will be contacted soon!" on an alert

  @EMR.UC6.US6 @Regression @Issue.546
  Scenario: Employer can call the Driver of a selected Trip Manifest
    Given Filling database and login as employer using cookies
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee with check_in in "Morning" and check_out in "Evening"
    And Select Employee Trip Request "check_in" for "Today" fast
    Then I should see "1" Employee Trip Requests for "check_in"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    When I wait for "3" seconds
    Then I assign driver to last manifest
    When I click link "Manifest"
    When I call driver "1" on manifest
    When I wait for "2" seconds
    Then I should see "You will be contacted soon!" on an alert


@Regression @Issue.635
Scenario: Guards who missed their last trip can be assigned to next trip
    Given Filling database and login as employer using cookies
    Given I create admin in database
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee with check_in in "45 Mins" and check_out in "2 Hours"
    When I create trip roster of "1" trip requests
    Given I create guard in database
    Then I assign guard to last manifest
    Then I assign driver to last manifest
    Then Set business associate of driver
    Given Driver accept income trip request
    Given Driver arrived request
    Given Start trip by driver request
    Given Driver onboards passanger request
    Given Driver completed a trip route request
    Given Set Employee Trip Status of Guard as missed
    Given I create "0" male employees and "1" female employees in database
    When I create new shift with check_in "02:00" and check_out "04:00"
    Then I create trip for employee -"4" for "Today"
    Given I am on "/trips"    
    Given I click link "Manifest"
    When I open the employee trip Manifest -"1"
    Given I click link "Add Guard" 
    Then should see name of Guard -"1"