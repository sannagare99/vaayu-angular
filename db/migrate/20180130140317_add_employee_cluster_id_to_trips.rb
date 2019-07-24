class AddEmployeeClusterIdToTrips < ActiveRecord::Migration[5.0]
  def change
    add_reference :trips, :employee_cluster, foreign_key: true
  end
end
