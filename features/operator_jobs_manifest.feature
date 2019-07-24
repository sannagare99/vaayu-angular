@javascript
Feature: Testing operator jobs manifest tab
  Background:
    Given I create companies in database
    Given I create site in database
    Given I create employer in database
    Given I create operator in database

  Scenario: Operator views all trip manifests properly, sorted by time, with alert sign for females and can delete manifest.
    Given I create male employee in database
    Given I create female employee in database
    Given Create Trip roster with 2 employees - male and female
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    Then I should see created trip manifests ordered by time
    Then I should see alert sign for female trips
    When I delete a manifest
    Then I should not see deleted manifest

  Scenario: Operator can open a selected manifest and view all trip details
    Given I create female employee in database
    Given Create Trip roster with 1 employee - female
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I open the female employee trip Manifest
    Then I should see correct Manifest information

  Scenario: Operator can view appropriate action in an unassigned manifest for normal trips
    Given I create male employee in database
    Given Create Trip roster with 1 employee - male
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I open the male employee trip Manifest
    Then I should see appropriate actions in unassigned manifest normal trip

  Scenario: Operator can view appropriate action in an unassigned manifest for alerted trips
    Given I create female employee in database
    Given Create Trip roster with 1 employee - female
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I open the female employee trip Manifest
    Then I should see appropriate actions in unassigned manifest alerted trip

  Scenario: Operator can view available drivers and their details
    Given I create male employee in database
    Given I create driver in database
    Given Driver check in request
    Given Create Trip roster with 1 employee - male
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I try to see available drivers for first manifest
    Then I should see listed details of available drivers

  Scenario: Operator can dispatch driver and view the assigned driver
    Given I create male employee in database
    Given I create driver in database
    Given Driver check in request
    Given Create Trip roster with 1 employee - male
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I try to see available drivers for first manifest
    Then I should see listed details of available drivers
    When I assign the driver to given manifest
    Then I should be able to see the assigned driver

  Scenario: Operator can view the route of the trip on map
    Given I create male employee in database
    Given I create driver in database
    Given Driver check in request
    Given Create Trip roster with 1 employee - male
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I try to see available drivers for first manifest
    Then I should see listed details of available drivers
    When I assign the driver to given manifest
    Then I should be able to see the assigned driver
    When I open the male employee driver assigned trip Manifest
    And I Open map
    Then I can see the trip map