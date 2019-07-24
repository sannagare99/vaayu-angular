require File.expand_path(File.join(File.dirname(__FILE__), "../../", "support", "paths"))

def assign_driver trip
  # driver = Driver.where(status: 'on_duty').first
  if trip.update(:driver => @driver, :vehicle => @driver.vehicle)
    if trip.assign_driver!
      return true
    end
  end
  return false
end

Then(/^I assign driver to last manifest$/) do
  assign_driver(Trip.last)
end