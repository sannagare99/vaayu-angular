class AddClusterErrorToEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :cluster_error, :text
  end
end