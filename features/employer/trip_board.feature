@javascript
Feature: Testing Employee Trips Notification by Employer login under Trip board Tab 

  @EMR.UC8.US3
  Scenario: Employer can view the Trip Manifest Modal by double clicking a particular trip from the Trip Board
    Given Filling database and login as employer using cookies
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee with check_in in "45 Mins" and check_out in "2 Hours"
    When I create trip roster of "1" trip requests
    Then I assign driver to last manifest
    Given I am on "/trips#employee-trip-request"
    When I click link "Trip Board"
    Then I double click on the element ".trip-info" of Trip "1" it shows the tooltip "(To Work)"
    Then I should check for "Process Code" for all employees in selected manifest for "check_in" in Trip Board
    Then I should check for "Sex" for all employees in selected manifest for "check_in" in Trip Board
    Then I should check for "ETA" for all employees in selected manifest for "check_in" in Trip Board
    Then I should check for "Start Shift" for all employees in selected manifest for "check_in" in Trip Board

  @EMR.UC8.US4
  Scenario: Employer can view the Trip Manifest Modal by double clicking a particular trip from the Trip Board
    Given Filling database and login as employer using cookies
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee with check_in in "45 Mins" and check_out in "2 Hours"
    # And Select Employee Trip Request "check_in" for "Today" fast
    # Then I should see "1" Employee Trip Requests for "check_in"
    # When Buttons "Create Trip Roster" pressed
    # Then Wait for modal "Create New Trip Roster"
    # When Buttons "Submit" pressed
    When I create trip roster of "1" trip requests
    Then I assign driver to last manifest
    Given I am on "/trips#employee-trip-request"
    When I click link "Trip Board"
    Then I hover over the element ".trip-info" of Trip "1" it shows the tooltip "Assign Trip Requested"
    Given Driver accept income trip request
    Given Page Refreshed
    When I click link "Trip Board"
    Then I hover over the element ".trip-info" of Trip "1" it shows the tooltip "Driver Accepted Trip"
    Given Driver arrived request
    Given Page Refreshed
    When I click link "Trip Board"
    Then I hover over the element ".trip-info" of Trip "1" it shows the tooltip "Driver Accepted Trip"
    Given Start trip by driver request
    Given Page Refreshed
    When I click link "Trip Board"
    Then I hover over the element ".trip-info" of Trip "1" it shows the tooltip "Active Trip"
    Given Driver completed a trip route request
    Given Page Refreshed
    When I click link "Trip Board"
    Then I hover over the element ".trip-info" of Trip "1" it shows the tooltip "Active Trip"



  @EMR.UC8.US5
  Scenario: Employer views all Trips that require an action
    Given I create companies in database
    Given I create employer in database
    Given I create operator in database
    Given I create data for employer jobs trip board with exception
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/trips"
    When I click link "Trip Board"
    Then I should see alerted trips in correct priority order on trip timeline for employer jobs trip board

  @Issue.537 @Regression
  Scenario: Stateful Trips: Status of Trip should be consistent
    Given Filling database and login as employer using cookies
    Given I create admin in database
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee with check_in in "45 Mins" and check_out in "2 Hours"
    When I create trip roster of "1" trip requests
    Then I assign driver to last manifest
    Then Set business associate of driver
    Given Driver accept income trip request
    When I click link "Trips"
    When I click link "Trip Board"
    Then I double click on the element ".trip-info" of Trip "1" it shows the tooltip "(Driver Accepted Trip)"