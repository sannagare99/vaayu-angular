@javascript
Feature: Testing Employee APIs

  @EMR.UC4.US5 @Regression @Issue.651 @Issue.666
  Scenario: Employer can approve an on-demand trip Request
    Given Filling database and login as employer using cookies
    Given Employee Create Trip request
    And Select Employee Trip Request "check_in" for "Today"
    Given Employee Trip Request accepted
    Then I should see API Employee Trip Requests for "check_in"