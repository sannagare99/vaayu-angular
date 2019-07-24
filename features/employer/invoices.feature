@javascript
Feature: Testing operator dashboard

Background:
    Given I create companies in database
    Given I create employer in database

@EMR.UC9.US1
Scenario: Employer manually generates a bill
    Given I create data for daily macro parameters in the employer billing
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/invoices"
    When I click link "Completed Trips"
    When I generate invoice of daily trip
    When I click link "Customer Invoices"
    Then I should see invoice generated for the daily trip

@EMR.UC9.US3
Scenario: Employer views a generated BIll
    Given I create data for daily macro parameters in the employer billing
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/invoices"
    When I generate invoice of daily trip in database
    When I click link "Customer Invoices"
    When I view generated invoice
    Then Wait for modal "Detail"
    Then I should see details of invoice generated

@EMR.UC9.US5
Scenario: Employer approves a Bill
    Given I create data for daily macro parameters in the employer billing
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/invoices"
    When I generate invoice of daily trip in database
    When I click link "Customer Invoices"
    When I open status of generated invoice
    When I set status of invoice as "Approved"
    Then I see status of invoice as "Approved"

@EMR.UC9.US7
Scenario: Employer marks a BILL as dirty
    Given I create data for daily macro parameters in the employer billing
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/invoices"
    When I generate invoice of daily trip in database
    When I click link "Customer Invoices"
    When I open status of generated invoice
    When I set status of invoice as "Dirty"
    Then I see status of invoice as "Dirty"

@EMR.UC9.US9
Scenario: Employer marks a Bill as paid
    Given I create data for daily macro parameters in the employer billing
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/invoices"
    When I generate invoice of daily trip in database
    When I click link "Customer Invoices"
    When I open status of generated invoice
    When I set status of invoice as "Paid"
    Then I see status of invoice as "Paid"

@EMR.UC9.US12
Scenario: Employer views the status a Bill
    Given I create data for daily macro parameters in the employer billing
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/invoices"
    When I generate invoice of daily trip in database
    When I click link "Customer Invoices"
    Then I see status of invoice as "New"

@EMR.UC9.US13
Scenario: Employer downloads a Bill
    Given I create data for daily macro parameters in the employer billing
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/invoices"
    When I generate invoice of daily trip in database
    When I click link "Customer Invoices"
    When I select invoice of daily trip
    When I download invoice of daily trip