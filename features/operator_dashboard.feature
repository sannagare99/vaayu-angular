@javascript
Feature: Testing operator dashboard

Background:
    Given I create companies in database
    Given I create employer in database

Scenario: Operator views daily macro parameters in the operator dashboard
    Given I create data for daily macro parameters in the operator dashboard
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/?period=day"
    Then I can see macro parameters in the operator dashboard

Scenario: Operator views weekly and monthly macro parameters in the operator dashboard
    Given I create data for weekly and monthly macro parameters in the operator dashboard
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/?period=week"
    Then I can see macro parameters in the operator dashboard
    Given I am on "/?period=month"
    Then I can see macro parameters in the operator dashboard

Scenario: Operator views daily micro parameters in the operator dashboard
    Given I create data for daily macro parameters in the operator dashboard
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/?period=day"
    Then I can see micro parameters in the operator dashboard

Scenario: Operator views weekly and monthly micro parameters in the operator dashboard
    Given I create data for weekly and monthly macro parameters in the operator dashboard
    Given I am on "/"
    Given I am try to log in as operator
    Given I am on "/?period=week"
    Then I can see micro parameters in the operator dashboard
    Given I am on "/?period=month"
    Then I can see micro parameters in the operator dashboard