@javascript
Feature: Testing operator billing

Background:
    Given I create companies in database
    Given I create employer in database

Scenario: Operator should be able to see all customer invoices with their statuses
	Given I create customer invoice data for operator billing
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/invoices"
    When I click link "Customer Invoices"
    Then I should see all the customer invoices with their statuses

Scenario: Operator should be able to see all business associate invoices with their statuses
	Given I create BA invoice data for operator billing
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/invoices"
    When I click link "BA Invoices"
    Then I should see all the BA invoices with their statuses