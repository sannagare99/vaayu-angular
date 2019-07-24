@javascript
Feature: Testing operator provisioning

  Background:
    Given Go to Operator Provisioning page

  Scenario: Operator has the ability to add new customers
    Given Go to Operator Provisioning page ".employee-company" tab
    When I click to ".add-new-item"
    Then Wait for operator modal "Add New Company"
    When I submit new customer form
    Then I should see "The company name length must be more than 3 characters"
    Given Fill form new customer data
    When I submit new customer form
    Then I should see new customer
  
  @Regression @Issue.607
  Scenario: Operator has the ability to delete customers
    Given Go to Operator Provisioning page ".employee-company" tab
    When I click to ".editor_remove"
    Then Wait for operator modal "Delete company"
    When I click to ".modal-content .btn-primary"
    Then I should see no customer
  
  @Regression @Issue.603
  Scenario: Operator has the ability to edit new employers
    Given Go to Operator Provisioning page ".employers" tab
    When I click to ".employer_edit"
    Then Wait for operator modal "Edit customer"
    Then I should see employer's details
  
  @Regression @Issue.602
  Scenario: [BUG]Operator has the ability to add new employers
    Given Go to Operator Provisioning page ".employers" tab
    When I click to ".add-new-item"
    Then Wait for operator modal "Add New Customer"
  
  @Regression @Issue.608
  Scenario: Operator has the ability to add new customers
    Given I create operator shift manager
    Given Go to Operator Provisioning page ".operator_shift_managers" tab
    When I click to ".profile-nav .fa-angle-down"
    Then I should see "Log Out"
    When I click link "Log Out"
    When I reset password of Operator Shift Manager
    And I fill password fields with new passwords for regression
    Then I should see "You need to sign in or sign up before continuing."

  Scenario: Operator has the ability to add business associate
    Given Go to Operator Provisioning page ".business-associates" tab
    When I click to ".add-new-item"
    Then Wait for operator new business associate form with label "Primary Administrator:"
    When I submit new business associate form
    Then I should see "Pan can't be blank"
    And I should see "Pan is the wrong length (should be 10 characters)"
    And I should see "Tan can't be blank"
    And I should see "Tan is the wrong length (should be 10 characters)"
    And I should see "Name can't be blank"
    And I should see "Legal name can't be blank"
    And I should see "Hq address can't be blank"
    And I should see "Service tax no is the wrong length (should be 15 characters)"
    When I click to ".add-new-item"
    Then Wait for operator new business associate form with label "Primary Administrator:"
    Given Operator fills form new business associate data
    When I submit new business associate form
    Then I should see new business associate

  Scenario: Operator has the ability to add new Vehicles
    Given Go to Operator Provisioning page ".vehicles" tab
    When I click to ".add-new-item"
    Then Wait for operator vehicle form with label "Info:"
    When I submit new vehicle form
    Then I should see "Plate number can't be blank"
    And I should see "Make can't be blank"
    And I should see "Model can't be blank"
    And I should see "Colour can't be blank"
    And I should see "Rc book no can't be blank"
    And I should see "Registration date can't be blank"
    And I should see "Insurance date can't be blank"
    And I should see "Permit type can't be blank"
    And I should see "Permit validity date can't be blank"
    And I should see "Make year can't be blank"
    And I should see "Device can't be blank"
    When I click to ".add-new-item"
    Then Wait for operator vehicle form with label "Info:"
    Given Fill form new vehicle data
    When I submit new vehicle form
    Then I should see "Vehicle was successfully created"
    Then I should see new vehicle

  Scenario: Operator has the ability to add new Drivers
    Given Go to Operator Provisioning page ".drivers" tab
    When I click to ".add-new-item"
    Then Wait for operator new driver form with label "Driver attributes:"
    When I submit new driver form
    Then I should see "can't be blank"
    Given Operator fills form new driver data
    When I submit new driver form
    Then I should see new driver
