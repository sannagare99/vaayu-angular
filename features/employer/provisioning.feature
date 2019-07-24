@javascript
Feature: Testing provisioning
    
  @EMR.UC2.US1 @Regression @Issue.566
  Scenario: Test employer have ability to add new employee
    Given Go to Provisioning page
    Given Go to Provisioning page ".employees" tab
    When I click to ".add-new-item"
    #Then Wait for modal "Add New Employee"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new employee data
    # Given Go to Provisioning page ".employees" tab
    When I submit new employee form
    Then I should see "User was successfully created"
    Then I should see new employee

  @Issue.617 @Regression
  Scenario: Check ability to see the profile of employer
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    When I am try to log in as employer
    Then I should see "Signed in successfully."
    When I click to ".profile-nav .fa-angle-down"
    Then I should see "Profile"
    When I click link "Profile"
    Then I should see "User Profile"
  
  @Issue.528 @Regression
  Scenario: Employee provisioned through Ingest - Contact Number should not appear with a decimal point
    Given Go to Provisioning page
    Given Go to Provisioning page ".employees" tab
    When I click to ".ingest"
    #Then Wait for modal "Add New Employee"
    Then I should see "Ingest Schedule"
    Given Upload Excel of Employee data
    Given I am on "/provisioning"
    Given Go to Provisioning page ".employees" tab
    Then I should see correct format of phone of new employee of employee excel

  @Issue.609 @Regression
  Scenario: Ingest - Employee Creation- Welcome moove Email should be sent to the Employee address
    Given Go to Provisioning page
    Given Go to Provisioning page ".employees" tab
    When I click to ".ingest"
    #Then Wait for modal "Add New Employee"
    Then I should see "Ingest Schedule"
    Given Upload Excel of Employee data
    Given I am on "/provisioning"
    Given Go to Provisioning page ".employees" tab
    Then I should see correct format of phone of new employee of employee excel
    Then Mail should be sent to the new employee
    
  @Issue.529 @Regression
  Scenario: Shift provisioned through ingested file should appear in Shifts Provisioning tab 
    Given Go to Provisioning page
    Given Go to Provisioning page ".employees" tab
    When I click to ".ingest"
    #Then Wait for modal "Add New Employee"
    Then I should see "Ingest Schedule"
    Given Upload Excel of Employee data
    Given I am on "/provisioning"
    Given Go to Provisioning page ".employees" tab
    Then I should see correct format of phone of new employee of employee excel
    When I open schedule of recent employee
    When I click to ".datepicker-days" calendar on "Tomorrow" date for regression
    Then I should see Shift timings of excel

  @Regression @Issue.532
  Scenario: Employer edits the shift of an employee after adding a partial shift 
    Given Use Chrome driver for testing
    Given Go to Provisioning page by setting cookies
    Given Go to Provisioning page ".employees" tab
    When I create 2 shifts for Shift Provisioning
    When I click to ".employer_edit"
    When Open Select Shift dropdown
    When I click to ".submit-btn"
    When I wait for "2" seconds
    When I click to ".setup_schedule"
    When I click to ".datepicker-current-week" calendar on "Tomorrow" date for regression
    When I select "1" shift for check in
    # When I select "1" shift for check out
    When I select location for shift
    When I save selected shifts
    When I click to ".setup_schedule"
    When I click to ".datepicker-current-week" calendar on "Tomorrow" date for regression
    Then I should see Shift timings "1"
    When I select "2" shift for check in
    When I select "2" shift for check out
    When I select location for shift
    When I save selected shifts
    When I click to ".setup_schedule"
    When I click to ".datepicker-current-week" calendar on "Tomorrow" date for regression
    Then I should see Shift timings "2"

  @EMR.UC2.US1
  Scenario: Test employer should not be able to add new employee without all mandatory fields
    Given Go to Provisioning page
    Given Go to Provisioning page ".employees" tab
    When I click to ".add-new-item"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new Employee data without "First Name"
    When I submit new employee form
    Then I should see error for "First Name" field as "can't be blank"
    When I click to ".cancel"
    Then I should not see new employee
    Given Page Refreshed
    When I click to ".add-new-item"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new Employee data without "Last Name"
    When I submit new employee form
    Then I should see error for "Last Name" field as "can't be blank"
    When I click to ".cancel"
    Then I should not see new employee
    Given Page Refreshed
    When I click to ".add-new-item"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new Employee data without "Phone"
    When I submit new employee form
    Then I should see error for "Phone" field as "can't be blank"
    When I click to ".cancel"
    Then I should not see new employee
    Given Page Refreshed
    When I click to ".add-new-item"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new Employee data without "Email"
    When I submit new employee form
    Then I should see error for "Email" field as "can't be blank"
    When I click to ".cancel"
    Then I should not see new employee
    Given Page Refreshed
    When I click to ".add-new-item"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new Employee data without "Gender"
    When I submit new employee form
    When I wait for "5" seconds
    Then I should not see new employee
    Then I should see "Gender can't be blank"
    # When I click to ".add-new-item"
    # Then Wait for employer form "Employee attributes:"
    # Given Fill form new Employee data without "Company"
    # When I submit new employee form
    # Then I should see error for "Company" field as "can't be blank"
    # When I cancel new employee form
    # Then I should not see new employee
    Given Page Refreshed
    When I click to ".add-new-item"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new Employee data without "Site"
    When I submit new employee form
    Then I should see error for "Home Address" field as "unable to calculate distance from home to site, please use valid address"
    When I click to ".cancel"
    Then I should not see new employee
    Given Page Refreshed
    When I click to ".add-new-item"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new Employee data without "Home Address"
    When I submit new employee form
    Then I should see error for "Home Address" field as "can't be blank"
    When I click to ".cancel"
    Then I should not see new employee
    Given Page Refreshed
    When I click to ".add-new-item"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new Employee data without "Zone"
    When I submit new employee form
    When I wait for "5" seconds
    Then I should not see new employee
    Then I should see "Zone can't be blank"

  @EMR.UC2.US1
  Scenario: Test employer should not be able to add new employee with duplicate details
    Given Go to Provisioning page
    Given Go to Provisioning page ".employees" tab
    When I click to ".add-new-item"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new Employee data with duplicate "Phone"
    When I submit new employee form
    Then I should see error for "Phone" field as "has already been taken"
    When I click to ".cancel"
    Given Page Refreshed
    When I click to ".add-new-item"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new Employee data with duplicate "Email"
    When I submit new employee form
    Then I should see error for "Email" field as "has already been taken"
  
  @EMR.UC2.US4
  Scenario: Test employer should not be able to add new transport desk manager without all mandatory fields
    Given Go to Provisioning page
    Given Go to Provisioning page ".transport_desk_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Transport Desk" Manager form attributes
    Given Fill form new manager data without "First Name"
    When I submit new "Transport Desk" manager form
    Then I should see "F name can't be blank"
    Then I should not see new "Transport Desk" manager
    When I click to ".add-new-item"
    Then Wait for "Transport Desk" Manager form attributes
    Given Fill form new manager data without "Last Name"
    When I submit new "Transport Desk" manager form
    Then I should see "L name can't be blank"
    Then I should not see new "Transport Desk" manager
    When I click to ".add-new-item"
    Then Wait for "Transport Desk" Manager form attributes
    Given Fill form new manager data without "Phone"
    When I submit new "Transport Desk" manager form
    Then I should see "Phone can't be blank"
    Then I should not see new "Transport Desk" manager
    When I click to ".add-new-item"
    Then Wait for "Transport Desk" Manager form attributes
    Given Fill form new manager data without "Email"
    When I submit new "Transport Desk" manager form
    Then I should see "Email can't be blank"
    Then I should not see new "Transport Desk" manager

  @EMR.UC2.US4
  Scenario: Test employer can't add new transport desk manager with duplicate details
    Given Go to Provisioning page
    Given Go to Provisioning page ".transport_desk_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Transport Desk" Manager form attributes
    Given Fill form new manager data with duplicate "Phone"
    When I submit new "Transport Desk" manager form
    Then I should see "Phone has already been taken"
    Then I should not see new "Transport Desk" manager
    When I click to ".add-new-item"
    Given Fill form new manager data with duplicate "Email"
    When I submit new "Transport Desk" manager form
    Then I should see "Email has already been taken"
    Then I should not see new "Transport Desk" manager
    
  @EMR.UC2.US4
  Scenario: Test employer have ability to add new transport desk manager
    Given Go to Provisioning page
    Given Go to Provisioning page ".transport_desk_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Transport Desk" Manager form attributes
    Given Fill form new manager data
    When I submit new "Transport Desk" manager form
    Then I should see "User was successfully created"
    Then I should see new "Transport Desk" manager
    
  @EMR.UC2.US2
  Scenario: Test employer should not be able to add new line manager without all mandatory fields
    Given Go to Provisioning page
    Given Go to Provisioning page ".line_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Line" Manager form attributes
    Given Fill form new manager data without "First Name"
    When I submit new "Line" manager form
    Then I should see "F name can't be blank"
    Then I should not see new "Line" manager
    When I click to ".add-new-item"
    Then Wait for "Line" Manager form attributes
    Given Fill form new manager data without "Last Name"
    When I submit new "Line" manager form
    Then I should see "L name can't be blank"
    Then I should not see new "Line" manager
    When I click to ".add-new-item"
    Then Wait for "Line" Manager form attributes
    Given Fill form new manager data without "Phone"
    When I submit new "Line" manager form
    Then I should see "Phone can't be blank"
    Then I should not see new "Line" manager
    When I click to ".add-new-item"
    Then Wait for "Line" Manager form attributes
    Given Fill form new manager data without "Email"
    When I submit new "Line" manager form
    Then I should see "Email can't be blank"
    Then I should not see new "Line" manager
    
  @EMR.UC2.US2
  Scenario: Test employer can't add new line manager with duplicate details
    Given Go to Provisioning page
    Given Go to Provisioning page ".line_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Line" Manager form attributes
    Given Fill form new manager data with duplicate "Phone"
    When I submit new "Line" manager form
    Then I should see "Phone has already been taken"
    Then I should not see new "Line" manager
    When I click to ".add-new-item"
    Given Fill form new manager data with duplicate "Email"
    When I submit new "Line" manager form
    Then I should see "Email has already been taken"
    Then I should not see new "Line" manager
    
  @EMR.UC2.US2
  Scenario: Test employer have ability to add new line manager
    Given Go to Provisioning page
    Given Go to Provisioning page ".line_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Line" Manager form attributes
    Given Fill form new manager data
    When I submit new "Line" manager form
    Then I should see "User was successfully created"
    Then I should see new "Line" manager

  @EMR.UC2.US6
  Scenario: Employer views Line Manager’s Employee List
    Given Go to Provisioning page
    Given I create "Line" Manager in database
    Given Go to Provisioning page ".line_managers" tab
    # Then I should see new "Line" manager
    When I click on Edit List for Line Manager "1"
    Then Wait for modal "Employee List"
    When I select "1" employees from employee list
    When Buttons "Save" pressed
    When I click on Edit List for Line Manager "1"
    Then I should see "1" employees selected in employee list

  @EMR.UC2.US7
  Scenario: Verify that Employer is able to search an Employee from Line Manager's employee list
    Given Go to Provisioning page
    Given I create "Line" Manager in database
    Given I create "1" employees in database
    Given Go to Provisioning page ".line_managers" tab
    # Then I should see new "Line" manager
    When I click on Edit List for Line Manager "1"
    Then Wait for modal "Employee List"
    When I fill Search Input with "Complete" name of Employee "1"
    Then I should see "1" employees with name matched with Search Input
    When I fill Search Input with "Complete" name of Employee "2"
    Then I should see "1" employees with name matched with Search Input

  @EMR.UC2.US7
  Scenario: Verify that Employer List search can shortens the list with every letter
    Given Go to Provisioning page
    Given I create "Line" Manager in database
    Given I create "1" employees in database
    Given Go to Provisioning page ".line_managers" tab
    # Then I should see new "Line" manager
    When I click on Edit List for Line Manager "1"
    Then Wait for modal "Employee List"
    When I fill Search Input with "Partial" name of Employee "1"
    Then I should see "1" employees with name matched with Search Input
    When I fill Search Input with "Partial" name of Employee "2"
    Then I should see "1" employees with name matched with Search Input
  
  # TODO: [BUG] Deselection of employee in employee list is not working
  @EMR.UC2.US8
  Scenario: Employer can edit a Line Manager’s Employee List
    Given Go to Provisioning page
    Given I create "Line" Manager in database
    Given Go to Provisioning page ".line_managers" tab
    # Then I should see new "Line" manager
    When I click on Edit List for Line Manager "1"
    Then Wait for modal "Employee List"
    When I select "1" employees from employee list
    When Buttons "Save" pressed
    When I click on Edit List for Line Manager "1"
    Then I should see "1" employees selected in employee list
    When I deselect "1" employees from employee list
    When Buttons "Save" pressed
    When I click on Edit List for Line Manager "1"
    Then I should see "0" employees selected in employee list
  
  @EMR.UC2.US5
  Scenario: Test employer should not be able to add new shift manager without all mandatory fields
    Given Go to Provisioning page
    Given Go to Provisioning page ".employer_shift_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Shift" Manager form attributes
    Given Fill form new manager data without "First Name"
    When I submit new "Shift" manager form
    Then I should see "F name can't be blank"
    Then I should not see new "Shift" manager
    When I click to ".add-new-item"
    Then Wait for "Shift" Manager form attributes
    Given Fill form new manager data without "Last Name"
    When I submit new "Shift" manager form
    Then I should see "L name can't be blank"
    Then I should not see new "Shift" manager
    When I click to ".add-new-item"
    Then Wait for "Shift" Manager form attributes
    Given Fill form new manager data without "Phone"
    When I submit new "Shift" manager form
    Then I should see "Phone can't be blank"
    Then I should not see new "Shift" manager
    When I click to ".add-new-item"
    Then Wait for "Shift" Manager form attributes
    Given Fill form new manager data without "Email"
    When I submit new "Shift" manager form
    Then I should see "Email can't be blank"
    Then I should not see new "Shift" manager
    
  @EMR.UC2.US5
  Scenario: Test employer have ability to add new shift manager
    Given Go to Provisioning page
    Given Go to Provisioning page ".employer_shift_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Shift" Manager form attributes
    Given Fill form new manager data
    When I submit new "Shift" manager form
    Then I should see "Employer shift manager was successfully created"
    Then I should see new "Shift" manager
    
  @Issue.680 @Regression
  Scenario: Shift Manager can login after Employer saves his details
    Given Go to Provisioning page
    Given Go to Provisioning page ".employer_shift_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Shift" Manager form attributes
    Given Fill form new manager data
    When I submit new "Shift" manager form
    Then I should see "Employer shift manager was successfully created"
    Then I should see new "Shift" manager
    When I click to ".profile-nav .fa-angle-down"
    Then I should see "Log Out"
    When I click link "Log Out"
    When I reset password of Shift Manager
    And I fill password fields with new passwords
    Then I should see "Your password has been changed successfully. You are now signed in."
    
  @EMR.UC2.US5
  Scenario: Test employer can't add new shift manager with duplicate details
    Given Go to Provisioning page
    Given Go to Provisioning page ".employer_shift_managers" tab
    When I click to ".add-new-item"
    Then Wait for "Shift" Manager form attributes
    Given Fill form new manager data with duplicate "Phone"
    When I submit new "Shift" manager form
    Then I should see "Phone has already been taken"
    Then I should not see new "Shift" manager
    When I click to ".add-new-item"
    Given Fill form new manager data with duplicate "Email"
    When I submit new "Shift" manager form
    Then I should see "Email has already been taken"
    Then I should not see new "Shift" manager
        
  @EMR.UC2.US3
  Scenario: Test employer have ability to add new guard
    Given Go to Provisioning page
    Given Go to Provisioning page ".guards" tab
    When I click to ".add-new-item"
    #Then Wait for modal "Add New Guard"
    Then Wait for Guard form attributes
    Given Fill form new guard data
    # Given Go to Provisioning page ".guards" tab
    When I submit new guard form
    Then I should see "User was successfully created"
    Then I should see new guard
    
  @EMR.UC2.US3
  Scenario: Test employer should not be able to add new guard without all mandatory fields
    Given Go to Provisioning page
    Given Go to Provisioning page ".guards" tab
    When I click to ".add-new-item"
    Then Wait for Guard form attributes
    Given Fill form new guard data without "First Name"
    When I submit new guard form
    When I wait for "5" seconds
    Then I should see "F name can't be blank"
    Then I should not see new guard
    When I click to ".add-new-item"
    Then Wait for Guard form attributes
    Given Fill form new guard data without "Last Name"
    When I submit new guard form
    Then I should see "L name can't be blank"
    Then I should not see new guard
    When I click to ".add-new-item"
    Then Wait for Guard form attributes
    Given Fill form new guard data without "Phone"
    When I submit new guard form
    Then I should see "Phone can't be blank"
    Then I should not see new guard
    When I click to ".add-new-item"
    Then Wait for Guard form attributes
    Given Fill form new guard data without "Email"
    When I submit new guard form
    Then I should see "Email can't be blank"
    Then I should not see new guard
    When I click to ".add-new-item"
    Then Wait for Guard form attributes
    Given Fill form new guard data without "Gender"
    When I submit new guard form
    When I wait for "5" seconds
    Then I should not see new guard
    Then I should see "Gender can't be blank"
    # When I click to ".add-new-item"
    # Then Wait for Guard form attributes
    # Given Fill form new guard data without "Company"
    # When I submit new guard form
    # Then I should see error for "Company" field as "can't be blank"
    # When I cancel new guard form
    # Then I should not see new guard
    When I click to ".add-new-item"
    Then Wait for Guard form attributes
    Given Fill form new guard data without "Site"
    When I submit new guard form
    Then I should see "Site can't be blank"
    Then I should not see new guard
    When I click to ".add-new-item"
    Then Wait for Guard form attributes
    Given Fill form new guard data without "Home Address"
    When I submit new guard form
    Then I should see "Home address can't be blank"
    Then I should not see new guard
    When I click to ".add-new-item"
    
  @EMR.UC2.US3
  Scenario: Test employer should not be able to add new guard with duplicate details
    Given Go to Provisioning page
    Given Go to Provisioning page ".guards" tab
    When I click to ".add-new-item"
    Then Wait for Guard form attributes
    Given Fill form new guard data with duplicate "Phone"
    When I submit new guard form
    Then I should see "Phone has already been taken"
    When I click to ".add-new-item"
    Then Wait for Guard form attributes
    Given Fill form new guard data with duplicate "Email"
    When I submit new guard form
    Then I should see "Email has already been taken"

  @EMR.UC2.US9
  Scenario: Employer cannot add a Zone without mandatory Field
    Given Go to Provisioning page
    Given Go to Provisioning page ".zones" tab
    When I click to ".add-new-item"
    When I submit new zone form
    Then I should see "Name can't be blank"
    Then I should not see new zone
  
  @EMR.UC2.US9
  Scenario: Employer cannot add a Zone with incorrect name entry
    Given Go to Provisioning page
    Given Go to Provisioning page ".zones" tab
    When I click to ".add-new-item"
    Given Fill incorrect new zone form
    When I submit new zone form
    Then I should see "Name is not a number"
    Then I should not see new zone

  @EMR.UC2.US9
  Scenario: Employer adds a Zone with correct details
    Given Go to Provisioning page
    Given Go to Provisioning page ".zones" tab
    When I click to ".add-new-item"
    When Fill new zone form
    When I submit new zone form
    Then I should see "Zone was successfully updated"
    Then I should see new zone

  @EMR.UC2.US10
  Scenario: Test employer have ability to add new shift
    Given Go to Provisioning page
    Given Go to Provisioning page ".shifts" tab
    When I click to ".add-new-item"
    Given Fill form new shift data
    When I submit new shift form
    Then I should see "Shift was successfully created"
    Then I should see new shift
  
  @EMR.UC2.US10
  Scenario: Test employer should not be able to add new shift without all mandatory fields
    Given Go to Provisioning page
    Given Go to Provisioning page ".shifts" tab
    When I click to ".add-new-item"
    Given Fill form new shift data without "Name"
    When I submit new shift form
    Then I should see error for "Name" field as "can't be blank"
    When I click to ".cancel"
    Then I should not see new shift
    Given Page Refreshed
    When I click to ".add-new-item"
    Given Fill form new shift data without "Start Time"
    When I submit new shift form
    Then I should see error for "Start Time" field as "can't be blank"
    When I click to ".cancel"
    Then I should not see new shift
    Given Page Refreshed
    When I click to ".add-new-item"
    Given Fill form new shift data without "End Time"
    When I submit new shift form
    Then I should see error for "End Time" field as "can't be blank"
    When I click to ".cancel"
    Then I should not see new shift