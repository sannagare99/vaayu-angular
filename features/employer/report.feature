@javascript
Feature: Testing employer report

Background:
    Given I create companies in database
    Given I create employer in database

@EMR.UC11.US4
Scenario: Employer views trip logs reports
    Given I create data for employer report
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports trip logs

@EMR.UC11.US10
Scenario: Employer downloads a report
    Given I create data for employer report
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports trip logs
    When I click link "Download"
    # Then I should get a download with the trip logs filename

@EMR.UC11.US11
Scenario: Employer sorts the columns of a report
    Given I create data for employer report
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports trip logs

@EMR.UC11.US18
Scenario: Employer views employee logs reports
    Given I create data for employer report
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports employee logs

@EMR.UC11.US19
Scenario: Employer views employee satisfaction reports
    Given I create data for employer report
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports employee satisfaction

@EMR.UC11.US20
Scenario: Employer views operations summary reports
    Given I create data for employer report
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports operations summary

@EMR.UC11.US21
Scenario: Employer views no show and cancellations reports
    Given I create data for employer report
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports no show and cancellations

@EMR.UC11.US22
Scenario: Employer views trip exceptions reports
    Given I create data for employer report
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports trip exceptions

@EMR.UC11.US23
Scenario: Employer views on time arrivals reports
    Given I create data for employer report
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports on time arrivals

@EMR.UC11.US24
Scenario: Employer views vehicle deployment reports
    Given I create data for employer report
    Then Set business associate of driver
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports vehicle deployment

@EMR.UC11.US25
Scenario: Employer views vehicle utilisation reports
    Given I create data for employer report
    Then Set business associate of driver
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports vehicle utilisation

@EMR.UC11.US26
Scenario: Employer views OTD reports
    Given I create data for employer report
    Then Set business associate of driver
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports OTD

@EMR.UC11.US27
Scenario: Employer views OTA reports
    Given Filling database and login as employer using cookies
    Given I create admin in database
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee with check_in in "45 Mins" and check_out in "2 Hours"
    When I create trip roster of "1" trip requests
    Then I assign driver to last manifest
    Then Set business associate of driver
    Given Driver accept income trip request
    Given Driver arrived request
    Given Start trip by driver request
    Given Driver onboards passanger request
    Given Driver completed a trip route request
    When I am on "/reports"
    Then I can see standard employer reports OTA

@Regression @Issue.548
Scenario: Data Inconsistency - Vehicle Deployment Report - Entry Selection should change based on filter change
    Given I create data for employer report
    Then Set business associate of driver
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employer reports vehicle deployment
    Then I can see correct shift time in vehicle deployment in employer reports
    When I change the date for employer reports for vehicle deployment
    Then I should see "No data available in table"


@Regression @Issue.550
Scenario: Data Inconsistency - OTA Report and OTD Report - Correct Delta In Arrival and Actual Departure time
    Given Filling database and login as employer using cookies
    Given I create admin in database
    Given I create "1" employees in database
    When I create schedule data for "Today" for "1" Employee with check_in in "45 Mins" and check_out in "2 Hours"
    When I create trip roster of "1" trip requests
    Then I assign driver to last manifest
    Then Set business associate of driver
    Given Driver accept income trip request
    Given Driver arrived request
    Given Start trip by driver request
    Given Driver onboards passanger request
    Given Driver completed a trip route request
    When I am on "/reports"
    Then I can see standard employer reports OTA
    Then I can see correct Delta In Arrival At Site for OTA in employer reports
    Then I can see correct Actual Depature Time At Site for OTD in employer reports

@Regression @Issue.562
Scenario: Data inconsistency and Downloading issue in Employees No Show Report. Correct Employee ID should be visible
    When I create employee no show data for employer report
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see standard employee no show reports

@Regression @Issue.564
Scenario: Data Incosistency in On Time Arrivals and On Time Departures Reports. Correct Logins canceled and logouts canceled should be shown
    Given I create cancelled trip data for employer report for check in
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see logins canceled in on time arrivals in employer reports
    Given I create canceled trip data for employer report for check out
    Then I can see logouts canceled in otd summary in employer reports

@Regression @Issue.564
Scenario: Data Incosistency in On Time Arrivals and On Time Departures Reports. Non-zero average delay should be visible
    Given I create completed trip data for employer report for check out
    Given I am on "/"
    Given I am try to log in as employer
    When I am on "/reports"
    Then I can see non-zero average delay in logout