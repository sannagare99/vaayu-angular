class AddStateToEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :state, :integer
  end
end
