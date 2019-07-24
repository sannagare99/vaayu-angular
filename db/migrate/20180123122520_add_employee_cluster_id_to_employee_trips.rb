class AddEmployeeClusterIdToEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    add_reference :employee_trips, :employee_cluster, foreign_key: true
  end
end
