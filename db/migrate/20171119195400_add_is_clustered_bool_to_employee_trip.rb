class AddIsClusteredBoolToEmployeeTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :is_clustered, :boolean, :default => false
  end
end