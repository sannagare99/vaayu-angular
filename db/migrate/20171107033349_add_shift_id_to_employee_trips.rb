class AddShiftIdToEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :shift_id, :integer
  end
end
