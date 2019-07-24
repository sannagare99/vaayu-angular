class AddZoneToEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :zone, :integer
  end
end