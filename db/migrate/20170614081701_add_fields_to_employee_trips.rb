class AddFieldsToEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :site_id, :integer
  end
end
