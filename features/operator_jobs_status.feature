@javascript
Feature: Testing operator jobs status

Background:
    Given I create companies in database
    Given I create employer in database

Scenario: Operator views current status of active trips
    Given I create data for operator jobs status with exception
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    When I click link "Status"
    Then I should see correct status for every trip in status table for operator jobs
    And I should see alerted trip in status table for operator job

Scenario: Operator views notification history trips
    Given I create data for operator jobs status with exception
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    When I click link "Status"
    And I should see notification history of a trip in status table for operator job

Scenario: Operator views actions for active trips notification
    Given I create data for operator jobs status with exception
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    When I click link "Status"
    And I should see actions of a trip in status table for operator job