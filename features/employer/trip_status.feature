@javascript
Feature: Testing Notifications from each trip about the events and exceptions for Employer Login

Background:
    Given I create companies in database
    Given I create employer in database

@EMR.UC7.US1
Scenario: Employer receives Trip Notifications
    Given I create data for Employer Notifications with exception
    Then Employer receives notification for every trip in Database
    

@EMR.UC7.US2
Scenario: Employer views Trip Notifications
    Given I create data for Employer Notifications with exception
    Given I am on "/"
    When I am try to log in as admin
    Given I am on "/trips"
    When I click link "Status"
    Then I should see correct status for every trip in status table for Employer Notifications
    And I should see alerted trip in status table for Employer Notification

@EMR.UC7.US3
Scenario: Employer can view the historical status of a Trip
    Given I create data for Employer Notifications with exception
    Given I am on "/"
    When I am try to log in as admin
    Given I am on "/trips"
    When I click link "Status"
    Then I should see correct status for every trip in status table for Employer Notifications
    And I should see notification history of a trip in status table for employer login

@EMR.UC7.US4
Scenario: Employer can view count of unresolved notifications
    Given I create data for Employer Notifications with exception
    Given I am on "/"
    When I am try to log in as admin
    Given I am on "/trips"
    When I click link "Status"
    And I should see exception count in status table for employer login
    # When I wait for "4000" seconds

@EMR.UC7.US5
Scenario: Employer views the status of an Trip Notification
    Given I create data for Employer Notifications with exception
    Given I am on "/"
    When I am try to log in as admin
    Given I am on "/trips"
    When I click link "Status"
    Then I should see correct status for every trip in status table for Employer Notifications

@EMR.UC7.US6
Scenario: Employer can view the unresolved trip notifications
    Given I create data for Employer Notifications with exception
    Given I am on "/"
    When I am try to log in as admin
    Given I am on "/trips"
    When I click link "Status"
    Then I should see correct status for every trip in status table for Employer Notifications
    And I should see notification history of a trip in status table for employer login

@EMR.UC7.US7
Scenario: Employer views available actions for the Trip Notifications
    Given I create data for Employer Notifications with exception
    Given I am on "/"
    When I am try to log in as admin
    Given I am on "/trips"
    When I click link "Status"
    Then I should see correct status for every trip in status table for Employer Notifications
    And I should see alerted trip in status table for Employer Notification
    Then I should see "Move To Next Step"

@EMR.UC7.US8
Scenario: Employer views available actions for the Trip Notifications
    Given I create data for Employer Notifications with exception
    Given I am on "/"
    When I am try to log in as admin
    Given I am on "/trips"
    When I click link "Status"
    And I should see alerted trip in status table for Employer Notification
    When I click to "#move_to_next_step"
    Then I should see trip alerts resolved

@EMR.UC7.US9
Scenario: Employer views the list of reasons to annotate a Trip with exception
    Given I create data for Employer Notifications with exception
    Given I am on "/"
    When I am try to log in as admin
    Given I am on "/trips"
    When I click link "Status"
    When I open the employee trip status -"1"
    When Buttons "Complete with Exception" pressed
    Then I see multiple options for reasons to annotate a Trip with exception
    When I select reason for complete trip with exception
    When I click to "#complete-with-exception-submit"
    When I open the employee trip status -"1"
    Then I should see "Reason for Exception: Wrong Assignment"

@EMR.UC7.US10
Scenario: Employer views the list of reasons to annotate a Trip with exception
    Given I create data for Employer Notifications with exception
    Given I am on "/"
    When I am try to log in as admin
    Given I am on "/trips"
    When I click link "Status"
    When I open the employee trip status -"1"
    When Buttons "Complete with Exception" pressed
    # When I wait for "4000" seconds
    Then I see multiple options for reasons to annotate a Trip with exception
