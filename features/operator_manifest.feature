@javascript
Feature: Testing operator manifest tab
  Scenario: Correct create trip rosters and assign driver
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given Assign driver to trip roster
    Given I am logout
    When I am try to log in as employer
    Given I am on "/trips"
    Given I click link "Manifest"
    When I open new trip roster manifest
    Then Wait until find elem "#modal-trip-info"
    Then I should see right information in manifest modal

  Scenario: Test closing Assign Driver form
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#assign_driver"
    Then Wait until find elem "#assign-driver-table"
    When Buttons "×" pressed
    Then I should not see element "#assign-driver-table"

  Scenario: Test Complete With Exception Wrong Assignment
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Wrong Assignment Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Wrong Assignment"

#  Scenario: Test Complete With Exception Operator Didnt Assign
#    Given Filling database
#    Given I am on "/"
#    Given I am try to log in as employer
#    Given Create Trip roaster
#    Given I am logout
#    Given I am try to log in as operator
#    Given I am on "/trips"
#    Given I click link "Manifest"
#    When I click to "#complete_with_exception"
#    Then Wait until find elem "#exception_reasons_sm"
#    Then debug
#    Then I select Operator Didnt Assign Exception
#    Then I click link "Submit"
#    Then I click to ".btn-trip-info"
#    Then I should see "	Completed with Exception"

  Scenario: Test Complete With Exception Network Issue
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Network Issue Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Network Issue"

  Scenario: Test Complete With Exception App Issue
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select App Issue Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: App Issue"

  Scenario: Test Complete With Exception Driver Didnt Accept
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Driver Didnt Accept Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Driver Didn’t Accept"

  Scenario: Test Complete With Exception Driver Was Off Duty
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Driver Was Off Duty Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Driver Was Off Duty"

#  Scenario: Test Complete With Exception Trip was cancelled
#    Given Filling database
#    Given I am on "/"
#    Given I am try to log in as employer
#    Given Create Trip roaster
#    Given I am logout
#    Given I am try to log in as operator
#    Given I am on "/trips"
#    Given I click link "Manifest"
#    When I click to "#complete_with_exception"
#    Then Wait until find elem "#exception_reasons_sm"
#    Then I select Trip was cancelled Exception
#    Then I click link "Submit"
#    Then I click to ".btn-trip-info"
#    Then I should see "Reason for Exception: Trip was cancelled"

  Scenario: Test Complete With Exception Driver Completed Trip
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Driver Completed Trip Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Driver Completed Trip"

  Scenario: Test Complete With Exception Other
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select other Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Completed with Exception"

  Scenario: Test closing Complete With Exception form
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    When Buttons "×" pressed
    Then I should not see element "#exception_reasons_sm"

  Scenario: Test opening and closing unassigned roster modal form
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    Then I click to ".unassigned-roster-btn"
    Then Wait until find elem "#modal-operator-unassigned-rosters"
    When Buttons "×" pressed
    Then I should not see element "#modal-operator-unassigned-rosters"

  Scenario: Test assign driver in unassigned roster modal form
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    Then I click to ".unassigned-roster-btn"
    Then Wait until find elem "#modal-operator-unassigned-rosters"
    Then I click to "#assign-trip-roster-modal"
    Then I assign driver
    Given I click link "Manifest"
    When I open new trip roster manifest
    Then Wait until find elem "#modal-trip-info"
    Then I should see right information in manifest modal

  Scenario: Test Delete roster in unassigned roster modal form
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    Then I click to ".unassigned-roster-btn"
    Then Wait until find elem "#modal-operator-unassigned-rosters"
    Then I click to "#delete-roster"
    Given I click link "Status"
    Given I click link "Manifest"
    Then I should see "No data available in table"

  Scenario: Test Complete With Exception Uber
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Wrong Assignment Exception
    Then I click link "Book Ola/Uber"
    Then I should see "Uber"
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Uber"

  Scenario: Test closing uber modal form
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Wrong Assignment Exception
    Then I click link "Book Ola/Uber"
    Then I should see "Uber"
    When Buttons "×" pressed
    Then I should not see element "Uber"

  Scenario: Correct create trip rosters and change driver
    Given Filling database with two drivers
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given Assign driver to trip roster
    Given I click link "Change Driver"
    Then I select new driver
    When I click link "Dispatch"
    Then I click link "Submit"

  Scenario: Correct create on check OUT Direction trip rosters and change driver
    Given Filling database with two drivers
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given Assign driver to trip roster
    Given I click link "Change Driver"
    Then I select new driver
    When I click link "Dispatch"
    Then I click link "Submit"

  Scenario: Correct create trip and change driver in modal trip info
    Given Filling database with two drivers
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given Assign driver to trip roster
    When I open new trip roster manifest
    When I click to "#change-driver"
    Then I select new driver
    When I click link "Dispatch"
    Then I click link "Submit"

  Scenario: Correct create on check OUT Direction trip rosters and assign driver
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given Assign driver to trip roster
    Given I am logout
    When I am try to log in as employer
    Given I am on "/trips"
    Given I click link "Manifest"
    When I open new trip roster manifest
    Then Wait until find elem "#modal-trip-info"
    Then I should see right information in manifest modal

  Scenario: Test Complete on check OUT Direction With Exception Wrong Assignment
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Wrong Assignment Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Wrong Assignment"

  Scenario: Test Complete on check OUT Direction With Exception Uber
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Wrong Assignment Exception
    Then I click link "Book Ola/Uber"
    Then I should see "Uber"
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Uber"

  Scenario: Correct create trip and open map
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given Assign driver to trip roster
    When I open new trip roster manifest
    When I click to "#open-map"
    Then I should see "CLOSE MAP"

  Scenario: Correct create trip and broken car
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Trip roaster
    Given Assign driver to trip roster
    When I open new trip roster manifest
    When I click to "#car_broke_down"
    Then I click link "Car Broke Down"
    Then I should see "Broke Down"
    Then I click link "Car OK"
    Then I should see "Paired"

  Scenario: Test Complete on check OUT Direction With Exception Network Issue
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Network Issue Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Network Issue"

  Scenario: Test Complete on check OUT Direction With Exception App Issue
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select App Issue Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: App Issue"

  Scenario: Test Complete on check OUT Direction With Exception Driver Didnt Accept
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Driver Didnt Accept Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Driver Didn’t Accept"

  Scenario: Test Complete on check OUT Direction With Exception Driver Off Duty
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Driver Off Duty Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Driver Off Duty"

  Scenario: Test Complete on check OUT Direction With Exception Trip was cancelled
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Trip was cancelled Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Trip was cancelled"

  Scenario: Test Complete on check OUT Direction With Exception Driver Completed Trip
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select Driver Completed Trip Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Reason for Exception: Driver Completed Trip"

  Scenario: Test Complete on check OUT Direction With Exception Other
    Given Filling database
    Given I am on "/"
    Given I am try to log in as employer
    Given Create Employee Trip Request "check_out"
    And Select Employee Trip Request "check_out"
    And I click link "Approve"
    When Buttons "Create Trip Roster" pressed
    Then Wait for modal "Create New Trip Roster"
    When Buttons "Submit" pressed
    Given I am logout
    Given I am try to log in as operator
    Given I am on "/trips"
    Given I click link "Manifest"
    When I click to "#complete_with_exception"
    Then Wait until find elem "#exception_reasons_sm"
    Then I select other Exception
    Then I click link "Submit"
    Then I click to ".btn-trip-info"
    Then I should see "Completed with Exception"












