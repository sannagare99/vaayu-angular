@javascript
Feature: Testing Queue
  Scenario: Check correct work Queue tab
    Given Filling database
    Given I am on "/"
    When I am try to log in as employer
    And Employee create trip request "check_in"
    When I click link "Trips"
    When I click link "Queue"
    #Then debug
    And I click to "#trip-date"
    #And I select date table
    And I set on ".calendar.right .hourselect" value "11"
    And I set on ".calendar.right .minuteselect" value "30"
    And I set on ".calendar.right .ampmselect" value "PM"
    And I set on ".calendar.left .hourselect" value "12"
    And I set on ".calendar.left .ampmselect" value "AM"
    And Buttons "Apply" pressed
    And Check correct date and time of request
    And I click link "Cancel"
    Then I should see "No data available in table"
    And Employee create trip request "check_in"
    When I click link "Provision"
    When I click link "Trips"
    When I click link "Queue"
    And I click to "#trip-date"
    And I set on ".calendar.right .hourselect" value "11"
    And I set on ".calendar.right .minuteselect" value "30"
    And I set on ".calendar.right .ampmselect" value "PM"
    And I set on ".calendar.left .hourselect" value "12"
    And I set on ".calendar.left .ampmselect" value "AM"
    And Buttons "Apply" pressed
    And I click link "Approve"
    And Check correct date and time of request
    And Buttons "Cancel Request" pressed
    Then I should see "No data available in table"

    #    Then debug
#    And I click link "Employee Trip Requests"
#    And I click to "#trip-date"
#    And I set on ".calendar.right .hourselect" value "11"
#    And I set on ".calendar.right .minuteselect" value "30"
#    And I set on ".calendar.right .ampmselect" value "PM"
#    And I set on ".calendar.left .hourselect" value "12"
#    And I set on ".calendar.left .ampmselect" value "AM"
#    And Buttons "Apply" pressed
    #Then debug
#    Then I should see my trip roaster