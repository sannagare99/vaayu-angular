class AddCancelStatusToEmployeeTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :cancel_status, :text
  end
end