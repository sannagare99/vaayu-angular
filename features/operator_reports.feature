@javascript
Feature: Testing operator report

Background:
    Given I create companies in database
    Given I create employer in database

Scenario: Operator views trip logs reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports trip logs

Scenario: Operator views employee logs reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports employee logs

Scenario: Operator views vehicle deployment reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports vehicle deployment

Scenario: Operator views ota reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports ota

Scenario: Operator views otd reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports otd

Scenario: Operator views vhicle utilisation reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports vehicle utilisation

Scenario: Operator views employee no show reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports employee no show

Scenario: Operator views employee satisfaction reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports employee satisfaction

Scenario: Operator views operations summary reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports operations summary

Scenario: Operator views trip exceptions reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports trip exceptions

Scenario: Operator views on time arrivals reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports on time arrivals

Scenario: Operator views on time departures reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports on time departures

Scenario: Operator views no show and cancellations reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports no show and cancellations

Scenario: Operator views panic alarms reports
    Given I create data for operator report
    Given I am on "/"
    Given I am try to log in as operator
    When I am on "/reports"
    Then I can see standard operator reports panic alarms