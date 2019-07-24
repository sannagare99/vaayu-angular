@javascript
Feature: Testing Employer User login and password reset

  @EMR.UC1.US2
  Scenario: Check ability to login and logout of employer
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    When I am try to log in as employer
    Then I should see "Signed in successfully."
    When I click to ".profile-nav .fa-angle-down"
    Then I should see "Log Out"
    When I click link "Log Out"
    Then I should see "You need to sign in or sign up before continuing."

  @EMR.UC1.US1
  Scenario: Employer should not be able to login incorrect login details
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    When I am try to log in as employer with incorrect "Email"
    Then I should see "Invalid Username or password."
    When I am try to log in as employer with incorrect "Password"
    Then I should see "Invalid Username or password."

  @EMR.UC1.US1
  Scenario: Check ability to reset password for employer with correct email
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    Then I should see "Can't Access your Account?"
    When I click link "Can't Access your Account?"
    Then Wait for modal "Reset Password"
    Then I should see "Reset Password"
    And I fill "#user_email" field with employer's email
    When Buttons "Send reset link" pressed
    Then I should see "You will receive an email with instructions on how to reset your password in a few minutes."
  
  @EMR.UC1.US1
  Scenario: Check ability to reset password for employer with incorrect email
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    Then I should see "Can't Access your Account?"
    When I click link "Can't Access your Account?"
    Then Wait for modal "Reset Password"
    Then I should see "Reset Password"
    And I fill "#user_email" field with incorrect employer's email
    When Buttons "Send reset link" pressed
    Then I should see "not found"