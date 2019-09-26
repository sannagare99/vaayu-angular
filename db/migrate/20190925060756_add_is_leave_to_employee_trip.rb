class AddIsLeaveToEmployeeTrip < ActiveRecord::Migration[5.0]
  def change
  	add_column :employee_trips, :is_leave, :boolean, default: false
  end
end
