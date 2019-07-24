@javascript
Feature: Testing Employee Schedule Management by employer login

  # Scenario: Check ability to create shift data for employee
  #   Given Go to Provisioning page by setting cookies
  #   Given Go to Provisioning page ".employees" tab
  @EMR.UC3.US1 @Regression @Issue.612 @Issue.655 @Issue.612
  Scenario: Employer adds the shift of an employee
    Given Use Chrome driver for testing
    Given Go to Provisioning page by setting cookies
    Given Go to Provisioning page ".employees" tab
    When I create shift for Shift Provisioning
    When I click to ".employer_edit"
    When Open Select Shift dropdown
    When I submit employee form
    When I wait for "2" seconds
    When I click to ".setup_schedule"
    When I click to ".datepicker-days" calendar on "Tomorrow" date
    When I select "1" shift for check in
    When I select "1" shift for check out
    When I select location for shift
    When I save selected shifts
    When I click to ".setup_schedule"
    Then I should see Shift timings "1"

  @Issue.557 @Regression
  Scenario: Employer cannot add the shift of an employee without entering location data
    Given Go to Provisioning page by setting cookies
    Given Go to Provisioning page ".employees" tab
    When I create shift for Shift Provisioning
    When I click to ".employer_edit"
    When Open Select Shift dropdown
    When I click to ".submit-btn"
    When I wait for "2" seconds
    When I click to ".setup_schedule"
    When I click to ".datepicker-current-week" calendar on "Tomorrow" date for regression
    When I select "1" shift for check in
    When I select "1" shift for check out
    When I save selected shifts
    Then I should see error in schedule input

  @Issue.597 @Regression
  Scenario: [BUG]Employer saves the schedule of an employee in firefox
    Given Go to Provisioning page by setting cookies
    Given Go to Provisioning page ".employees" tab
    When I create shift for Shift Provisioning
    When I click to ".employer_edit"
    When Open Select Shift dropdown
    When I click to ".submit-btn"
    When I wait for "2" seconds
    When I click to ".setup_schedule"
    When I click to ".datepicker-current-week" calendar on "Tomorrow" date for regression
    When I select "1" shift for check in
    When I select "1" shift for check out
    When I select location for shift
    When I save selected shifts
    Then I should see "Setup Schedule"
    
  @EMR.UC3.US3 @Regression @Issue.533 @Issue.547
  Scenario: Employer views the shift of an employee
    Given Use Chrome driver for testing
    Given Go to Provisioning page by setting cookies
    Given Go to Provisioning page ".employees" tab
    When I create shift for Shift Provisioning
    When I click to ".employer_edit"
    When Open Select Shift dropdown
    When I submit employee form
    When I wait for "2" seconds
    When I click to ".setup_schedule"
    When I click to ".datepicker-days" calendar on "Tomorrow" date
    When I select "1" shift for check in
    When I select "1" shift for check out
    When I select location for shift
    When I save selected shifts
    When I click to ".setup_schedule"
    Then I should see Shift timings "1"

  @EMR.UC3.US4
  Scenario: Employer edits the shift of an employee
    Given Use Chrome driver for testing
    Given Go to Provisioning page by setting cookies
    Given Go to Provisioning page ".employees" tab
    When I create 2 shifts for Shift Provisioning
    When I click to ".employer_edit"
    When Open Select Shift dropdown
    When I submit employee form
    When I wait for "2" seconds
    When I click to ".setup_schedule"
    When I click to ".datepicker-days" calendar on "Tomorrow" date
    When I select "1" shift for check in
    When I select "1" shift for check out
    When I select location for shift
    When I save selected shifts
    When I click to ".setup_schedule"
    When I click to ".datepicker-days" calendar on "Tomorrow" date
    When I select "2" shift for check in
    When I select "2" shift for check out
    When I select location for shift
    When I save selected shifts
    When I click to ".setup_schedule"
    Then I should see Shift timings "2"

  @EMR.UC3.US6
  Scenario: Employer views the shift of an employee
    Given Use Chrome driver for testing
    Given Go to Provisioning page
    When I create 2 shifts for Shift Provisioning
    Given Go to Provisioning page ".employer_shift_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Shift" Manager form attributes
    Given Fill form new manager data
    When I submit new "Shift" manager form
    Then I should see "Employer shift manager was successfully created"
    When I click on Edit Shifts of employer shift manager
    Then Wait for modal "Shift"
    When I click to ".datepicker-days" calendar on "Tomorrow" date
    When I select "1" shift for check in of employer shift manager
    When I select "1" shift for check out of employer shift manager
    When I select location for shift of employer shift manager
    When I save selected shifts
    When I click on Edit Shifts of employer shift manager
    Then Wait for modal "Shift"
    When I click to ".datepicker-days" calendar on "Tomorrow" date
    Then I should see Shift timings "1" for employer shift manager

  @EMR.UC3.US7
  Scenario: Employer views the shift of an employee
    Given Use Chrome driver for testing
    Given Go to Provisioning page
    When I create 2 shifts for Shift Provisioning
    Given Go to Provisioning page ".employer_shift_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Shift" Manager form attributes
    Given Fill form new manager data
    When I submit new "Shift" manager form
    Then I should see "Employer shift manager was successfully created"
    When I click on Edit Shifts of employer shift manager
    Then Wait for modal "Shift"
    When I click to ".datepicker-days" calendar on "Tomorrow" date
    When I select "1" shift for check in of employer shift manager
    When I select "1" shift for check out of employer shift manager
    When I select location for shift of employer shift manager
    When I save selected shifts
    When I click on Edit Shifts of employer shift manager
    Then Wait for modal "Shift"
    When I click to ".datepicker-days" calendar on "Tomorrow" date
    When I select "2" shift for check in of employer shift manager
    When I select "2" shift for check out of employer shift manager
    When I save selected shifts
    When I click on Edit Shifts of employer shift manager
    Then Wait for modal "Shift"
    When I click to ".datepicker-days" calendar on "Tomorrow" date
    Then I should see Shift timings "2" for employer shift manager