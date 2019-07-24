@javascript
Feature: Testing employer dashboard

Background:
    Given I create companies in database
    Given I create employer in database

@EMR.UC11.US1
Scenario: Employer views daily macro parameters in the employer dashboard
    Given I create data for daily macro parameters in the employer dashboard
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/?period=day"
    Then I can see macro parameters in the employer dashboard

@Issue.576 @Regression
Scenario: Employer views Fleet Utilization in the employer dashboard
    Given I create data for daily macro parameters in the employer dashboard
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/?period=day"
    Then I should see "FLEET UTILIZATION"

@EMR.UC11.US2
Scenario: Employer views daily trip related micro parameters in the employer dashboard
    Given I create data for daily macro parameters in the employer dashboard
    Given I am on "/"
    Given I am try to log in as employer
    Given I am on "/?period=day"
    Then I can see macro parameters in the employer dashboard

# @EMR.UC11.US17
# Scenario: Employer views daily non-trip related micro parameters in the employer dashboard
#     Given I create data for daily macro parameters in the employer dashboard
#     Given I am on "/"
#     Given I am try to log in as employer
#     Given I am on "/?period=day"
#     Then I can see non-trip related micro parameters in the employer dashboard