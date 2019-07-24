@javascript
Feature: Employee Trip Requests
# Moved to features/employer/trip_requests.feature
  # Scenario: Employer should have ability to Cancel Request  on check IN Direction
  #   Given Filling database
  #   Given I am on "/"
  #   When I am try to log in as employer
  #   Given Create Employee Trip Request "check_in"
  #   And Select Employee Trip Request "check_in"
  #   And I click link "Approve"
  #   When Buttons "Cancel Request" pressed
  #   Then I should see "No data available in table"

  # Scenario: Employer should have ability to Create Trip Roster for specific employer  on check IN Direction
  #   Given Filling database
  #   Given I am on "/"
  #   When I am try to log in as employer
  #   Given Create Employee Trip Request "check_in"
  #   And Select Employee Trip Request "check_in"
  #   And I click link "Approve"
  #   When Buttons "Create Trip Roster" pressed
  #   Then Wait for modal "Create New Trip Roster"
  #   When Buttons "Submit" pressed
  #   Then In "#badge-assigned-trips" I should see "1"

  # Scenario: Employee should have ability to Create Trip Roster for specific employer  on check OUT Direction
  #   Given Filling database
  #   Given I am on "/"
  #   When I am try to log in as employer
  #   Given Create Employee Trip Request "check_out"
  #   And Select Employee Trip Request "check_out"
  #   And I click link "Approve"
  #   When Buttons "Create Trip Roster" pressed
  #   Then Wait for modal "Create New Trip Roster"
  #   When Buttons "Submit" pressed
  #   Then In "#badge-assigned-trips" I should see "1"

  # Scenario: Employer should have ability to Cancel Request on check OUT Direction
  #   Given Filling database
  #   Given I am on "/"
  #   When I am try to log in as employer
  #   Given Create Employee Trip Request "check_out"
  #   And Select Employee Trip Request "check_out"
  #   And I click link "Approve"
  #   When Buttons "Cancel Request" pressed
  #   Then I should see "No data available in table"

  # Scenario: Employee trip request should have all information about employee on check OUT Direction
  #   Given Filling database
  #   Given I am on "/"
  #   When I am try to log in as employer
  #   Given Create Employee Trip Request "check_out"
  #   And Select Employee Trip Request "check_out"
  #   Then I should see Employee Trip Requests

  # Scenario: Check auto adding trip request for employee before start and end work on check in and check out direction
  #   Given Filling database
  #   Given I am on "/"
  #   Given I am try to log in as employer
  #   Given Set employee schedule
  #   Given I click link "Trips"
  #   Given I click link "Queue"
  #   Given Search for auto created check in trip request
  #   Then I should see Employee Trip Requests
  #   Given Search for auto created check out trip request
  #   Then I should see Employee Trip Requests