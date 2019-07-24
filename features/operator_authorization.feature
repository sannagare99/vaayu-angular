@javascript

Feature: Operator Authorization

  Scenario: Operator should be able to login with valid credentials and logout
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    When I am try to log in whith username "operator@n3wnormal.com" and password "123123123"
    Then I should see "Invalid Username or password."
    When I am try to log in whith username "operator@n2wnormal.com" and password "password2"
    Then I should see "Invalid Username or password."
    When I am try to log in as operator
    Then I should see "Signed in successfully."
    When I click to ".profile-nav .fa-angle-down"
    Then I should see "Log Out"
    When I click link "Log Out"
    Then I should see "You need to sign in or sign up before continuing."


  Scenario: Operator should be able to reset password with valid email
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    Then I should see "Can't Access your Account?"
    When I click link "Can't Access your Account?"
    Then Wait for modal "Reset Password"
    Then I should see "Reset Password"
    And I fill "#user_email" field with operator's email
    When Buttons "Send reset link" pressed
    Then I should see "You will receive an email with instructions on how to reset your password in a few minutes."

Scenario: Operator should not be able to reset password with invalid email
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    Then I should see "Can't Access your Account?"
    When I click link "Can't Access your Account?"
    Then Wait for modal "Reset Password"
    Then I should see "Reset Password"
    And I fill "#user_email" field with invalid email
    When Buttons "Send reset link" pressed
    Then I should see "Please review the problems below:"
    And I should see "not found"