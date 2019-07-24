@javascript
Feature: Testing operator jobs trip jobs

Background:
    Given I create companies in database
    Given I create employer in database
    Given I create operator in database

Scenario: Operator views all the trips on the time horizon
    Given I create data for operator jobs trip board
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    When I click link "Trip Board"
    Then I should see active and inactive on trip timeline

Scenario: Operator views all the trips on the time horizon with alerts
    Given I create data for operator jobs trip board with exception
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    When I click link "Trip Board"
    Then I should see alerted trips in correct priority order on trip timeline
    And I should see correct hover text of trips on trip timeline

Scenario: Operator views all the actions for alerted trips
    Given I create data for operator jobs trip board with exception
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    When I click link "Trip Board"
    And I click on alerted trip
    Then I should see all correct trip action for the alerted trip

Scenario: Operator can take complete with exception action for alerted trips
    Given I create data for operator jobs trip board with exception
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    When I click link "Trip Board"
    And I click on alerted trip
    Then I should be able to confirm the alerted trip with exception


Scenario: Operator can take move to next step action for alerted trips
    Given I create data for operator jobs trip board with exception
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    When I click link "Trip Board"
    And I click on alerted trip
    Then I should be able to move to next step for alerted trip