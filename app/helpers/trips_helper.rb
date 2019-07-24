module TripsHelper

	def can_select_vehicle(driver, emp_count)
		driver.vehicle ? emp_count <= driver&.vehicle&.seats : false
	end
end
