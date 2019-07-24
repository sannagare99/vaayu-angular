@javascript
Feature: Testing provisioning

  Scenario: Test employer have ability to add new employee
    Given Go to Provisioning page
    Given Go to Provisioning page ".employees" tab
    When I click to ".add-new-item"
    #Then Wait for modal "Add New Employee"
    Then Wait for employer form "Employee attributes:"
    Given Fill form new employee data
    Given Go to Provisioning page ".employees" tab
    When I submit new employee form
    Then I should see "User was successfully created"
    Then I should see new employee
    #When I click link "Delete" created employee
    #When Buttons "Delete" pressed
    #Then I should not see deleted employee

  Scenario: Test closing Add New Employee form
    Given Go to Provisioning page
    Given Go to Provisioning page ".employees" tab
    When I click to ".add-new-item"
    #Then Wait for modal "Add New Employee"
    Then Wait for employer form "Employee attributes:"
    When I closed employer form
    #When I close modal "#m-employees-new"
    Then I should not see element "#form-employees"

  Scenario: Employer can set up Schedule to any employee and to any day
    Given Go to Provisioning page
    Given Go to Provisioning page ".employees" tab
    Then I should see existing employee
    When I click link "Setup Schedule"
    Then Wait for modal "Shift"
    Given I fill schedule fields for each day
    When Buttons "Save changes" pressed
    Then I should not see element "#modal-employee-schedule"
    When I click link "Setup Schedule"
    #Then I should see filled schedule

  Scenario: Employer can't create new employee without filling all required fields
    Given Go to Provisioning page
    Given Go to Provisioning page ".employees" tab
    When I click to ".add-new-item"
    #Then Wait for modal "Add New Employee"
    Then Wait for employer form "Employee attributes:"
    When Buttons "Save" pressed
    #Given Go to Provisioning page ".employees" tab
    Then I should see "can't be blank"
    #Then I should see "Email can't be blank, Email is not an email, Email username, phone and email cannot be same, Gender can't be blank, Home address can't be blank, Home address not found on Google Maps. Please use valid home address., Home address unable to calculate distance from home to site, please use valid address, Site can't be blank, Zone can't be blank, Username can't be blank, Username username, phone and email cannot be same, Phone can't be blank, Phone username, phone and email cannot be same, F name can't be blank, and L name can't be blank"

  Scenario: Employer have ability to add & delete new zone
    Given Go to Provisioning page
    Given I click link "Zones"
    When I click link "Add"
    Then I should see "NAME"
    Given Fill incorrect new zone form
    When Buttons "Save changes" pressed
    Then I should see "Name is not a number"
    When I click link "Add"
    Then I should see "NAME"
    When Fill new zone form
    When Buttons "Save changes" pressed
    Then I should see "Zone was successfully updated"
    Then I should see new zone
    When I try delete new zone
    Then I should see "Delete zone"
    When Buttons "Delete" pressed
    Then I should not see new zone

  Scenario: Test operator have ability to add new Transport Desk Managers
    Given Go to Operator Provisioning page
    #Given Go to Operator Provisioning page ".employers" tab
    #Temporary measure does not work button Add
    Given Go to Operator Provisioning page ".drivers" tab
    Given Go to Operator Provisioning page ".employers" tab
    When I click to ".add-new-item"
    Then Wait for modal "Add New Customer"
    Given Fill form new employer data
    When I submit new employer form
    Then I should see "User was successfully created"
    Then I should see new employer
    When I click link "Delete" created employer
    When Buttons "Delete" pressed
    Then I should not see deleted employer

  Scenario: Operator can't create new Transport Desk Managers without filling all required fields
    Given Go to Operator Provisioning page
    #Given Go to Operator Provisioning page ".employers" tab
    #Temporary measure does not work button Add
    Given Go to Operator Provisioning page ".drivers" tab
    Given Go to Operator Provisioning page ".employers" tab
    When I click to ".add-new-item"
    Then Wait for modal "Add New Customer"
    When Buttons "Submit" pressed
    Then I should see "*This field is required."

#  Scenario: Test operator have ability to add new Sites
#    Given Go to Operator Provisioning page
#    Given Go to Operator Provisioning page ".sites" tab
#    When I click to ".add-new-item"
#    Then Wait for modal "Add New Site"
#    Given Fill form new site data





