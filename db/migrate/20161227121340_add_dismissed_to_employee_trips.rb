class AddDismissedToEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :dismissed, :boolean, default: false
  end
end
