@javascript
Feature: Testing User login and profile

  Scenario: Check ability to login, logout and incorrect password login
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    When I am try to log in whith username "employer@n3wnormal.com" and password "123123123"
    Then I should see "Invalid Username or password."
    When I am try to log in whith username "employer@n2wnormal.com" and password "password2"
    Then I should see "Invalid Username or password."
    When I am try to log in as employer
    Then I should see "Signed in successfully."
    When I click to ".profile-nav .fa-angle-down"
    Then I should see "Log Out"
    When I click link "Log Out"
    Then I should see "You need to sign in or sign up before continuing."

  Scenario: Check ability to change first and last name in user profile
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    When I am try to log in as employer
    Then I should see "Signed in successfully."
    When I click to ".profile-nav .fa-angle-down"
    Then I should see "Log Out"
    And I click link "Profile"
    And I fill "#user_f_name" field with text "EmployerTest"
    And I fill "#user_l_name" field with text "LastNameTest"
    Then I click to ".btn-primary"
    And In ".profile-username" I should see "EmployerTest LastNameTest"
    And I fill "#user_f_name" field with text "Employer"
    And I fill "#user_l_name" field with text "Test"
    Then I click to ".btn-primary"
    Then I should see "Congratulations! Your profile was successfully updated."

  Scenario: Check ability Operator to change first and last name in user profile
    Given Filling database
    Given I am on "/"
    Then Wait until find elem ".lazy"
    When I am try to log in as operator
    Then I should see "Signed in successfully."
    When I click to ".profile-nav .fa-angle-down"
    Then I should see "Log Out"
    And I click link "Profile"
    And I fill "#user_f_name" field with text "TestOperator"
    And I fill "#user_l_name" field with text "LastNameTest"
    Then I click to ".btn-primary"
    And In ".profile-username" I should see "TestOperator LastNameTest"
    And I fill "#user_f_name" field with text "Operator"
    And I fill "#user_l_name" field with text "Test"
    Then I click to ".btn-primary"
    Then I should see "Congratulations! Your profile was successfully updated."



