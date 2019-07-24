class AddEmployeeTripsRouteOrder < ActiveRecord::Migration[5.0]
  def change
  	add_column :employee_trips, :route_order, :text
    add_column :trips, :is_manual, :boolean, :default => false
  end
end