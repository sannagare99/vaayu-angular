@javascript
Feature: Testing Employee Trips Requests Management by Employer login under Queue Tab

  @EMR.UC4.US1
  Scenario: Employer can view single Employee Trip Requests
    Given Filling database and login as employer using cookies
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee
    And Select Employee Trip Request "check_out" for "Today"
    Then I should see "1" Employee Trip Requests for "check_out"

  @EMR.UC4.US1
  Scenario: Employer can view multiple Employee Trip Requests
    Given Filling database and login as employer using cookies
    Given I create "5" employees in database
    When I create schedule data for "Today" for "5" Employee
    And Select Employee Trip Request "check_out" for "Today"
    Then I should see "5" Employee Trip Requests for "check_out"

  @EMR.UC4.US2
  Scenario: Employer can filter the requests based on date, time and direction
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    Given I create "3" employees in database
    When I create schedule data for "Tomorrow" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    And Select Employee Trip Request "check_in" for "Tomorrow"
    Then I should see "3" Employee Trip Requests for "check_out"
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "6" Employee Trip Requests for "check_out"
    When I click to "#trip-time"
    And I fill ".calendar.left .input-mini" field with text "12:00 PM"
    And I fill ".calendar.left .input-mini" field with text "12:00 PM"
    When Buttons "Apply" pressed
    Then I should see "3" Employee Trip Requests for "check_out"

  @EMR.UC4.US2
  Scenario: Employer can filter the requests based on date, time and direction
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    And Select Employee Trip Request "check_in" for "Today" fast
    Then I should see "3" Employee Trip Requests for "check_out"
    When I fill Trip Queue Search field with "Complete" name of Employee "2"
    When I click to "#queue-table_search"
    Then I should see "1" employee trip request with name matched with Search Input

  @EMR.UC4.US3
  Scenario: Employer views filtered Employee Trip Requests
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "6" Employee Trip Requests for "check_out"
    When I click to "#trip-time"
    And I fill ".calendar.left .input-mini" field with text "12:00 PM"
    And I fill ".calendar.left .input-mini" field with text "12:00 PM"
    When Buttons "Apply" pressed
    Then I should see "3" Employee Trip Requests for "check_out"
    When I select all Employee Trip Requests
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    Then I should see "3" Employee Trip Requests for confirm

  @EMR.UC4.US4
  Scenario: Employer can edit the shift time of a trip Request
    Given Filling database and login as employer using cookies
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee
    And Select Employee Trip Request "check_out" for "Today" fast
    Then I should see "1" Employee Trip Requests for "check_out"
    When I click to "#employee-trip-request-table tbody tr:nth-child(1) td:nth-child(1)"
    When I add "2" minutes to "check_out" shift time of trip request
    When Buttons "Update" pressed
    Then I find "check_out" shift time of trip request "1" updated


  @EMR.UC4.US6
  Scenario: Employer should have ability to Cancel Request on check IN Direction
    Given Filling database and login as employer using cookies
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "1" Employee Trip Requests for "check_in"
    When Buttons "Cancel Request" pressed
    Then I should see "0" Employee Trip Requests for "check_in"

  @EMR.UC4.US6
  Scenario: Employer should have ability to Cancel Request on check OUT Direction
    Given Filling database and login as employer using cookies
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee
    And Select Employee Trip Request "check_out" for "Today"
    Then I should see "1" Employee Trip Requests for "check_out"
    When Buttons "Cancel Request" pressed
    Then I should see "0" Employee Trip Requests for "check_out"

  @EMR.UC4.US6
  Scenario: Employer should have ability to Cancel Multiple Requests on check IN Direction
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "3" Employee Trip Requests for "check_in"
    When I select all Employee Trip Requests
    When Buttons "Cancel Request" pressed
    Then I should see "0" Employee Trip Requests for "check_in"

  @EMR.UC5.US1
  Scenario: Employer views a auto-generated Manifest on Check Out Direction
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_out" for "Today"
    Then I should see "6" Employee Trip Requests for "check_out"
    Then I should see "Multiple" Employee Trip Requests selected for Trip manifest

  @EMR.UC5.US1
  Scenario: Employer views a auto-generated Manifest on Check In Direction
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "6" Employee Trip Requests for "check_in"
    Then I should see "Multiple" Employee Trip Requests selected for Trip manifest

  @EMR.UC5.US1
  Scenario: Employer views a auto-generated Manifest on Check In Direction
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "6" Employee Trip Requests for "check_in"
    Then I should see "Multiple" Employee Trip Requests selected for Trip manifest

  @EMR.UC5.US2
  Scenario:  Employer can edit a auto-generated Manifest by selecting an extra employee
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "6" Employee Trip Requests for "check_in"
    Then I should see "Multiple" Employee Trip Requests selected for Trip manifest
    When I select "1" Employee Trip Requests for Trip manifest
    Then I should see Employee Trip Requests selected for Trip manifest incremented by "1"

  @EMR.UC5.US2
  Scenario:  Employer can edit a auto-generated Manifest by deselecting an extra employee
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "6" Employee Trip Requests for "check_in"
    Then I should see "Multiple" Employee Trip Requests selected for Trip manifest
    When I deselect "1" Employee Trip Requests for Trip manifest
    Then I should see Employee Trip Requests selected for Trip manifest incremented by "-1"

  @EMR.UC5.US3
  Scenario:  Employer can auto-create multiple Manifests by clicking on the Auto Cluster button in the Queue tab
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "6" Employee Trip Requests for "check_in"
    Then I should see "Multiple" Employee Trip Requests selected for Trip manifest
    When Buttons "Auto Cluster" pressed
    Then I should see "Multiple" Employee Trip Requests clusters

  @EMR.UC5.US3
  Scenario:  Employer can auto-create multiple Manifests and can select a set of employees to auto cluster.
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database with same address
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "6" Employee Trip Requests for "check_in"
    Then I should see "Multiple" Employee Trip Requests selected for Trip manifest
    When Buttons "Auto Cluster" pressed
    Then I should see "Multiple" Employee Trip Requests clusters
    Then I should see "Multiple" Employee Trip Requests for "check_in"
    When Buttons "Auto Cluster" pressed
    Then I should see "More" Employee Trip Requests clusters


  @Regression @Issue.542
  Scenario: Employer cannot select employees of different shifts for same trip roster Check In Direction
    Given Filling database and login as employer using cookies
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Morning" and check_out in "Evening"
    Given I create "3" employees in database
    When I create schedule data for "Today" for "3" Employee with check_in in "Afternoon" and check_out in "Midnight"
    And Select Employee Trip Request "check_in" for "Today"
    Then I should see "6" Employee Trip Requests for "check_in"
    Then I should see "Multiple" Employee Trip Requests selected for Trip manifest
    When I select "6" Employee Trip Requests for Trip manifest
    When Buttons "Create Trip Roster" pressed
    Then I should see "Cannot create manifests with different Shift Times!"

  @Regression @Issue.616
  Scenario: Ingest - Import manifest option should be available for Employer
    Given Filling database and login as employer using cookies
    Given I click link "Trips"
    Given I click link "Queue"
    Then I should see "Import Manifest"

  @Regression @Issue.618
  Scenario: Ingest - Ingest Employee schedule details should update Employee setup schedule
    Given Filling database and login as employer using cookies
    When I create 2 shifts for Shift Provisioning
    And I open import manifest excel modal
    When I upload excel and start worker
    Then I see trip request generated for these employees