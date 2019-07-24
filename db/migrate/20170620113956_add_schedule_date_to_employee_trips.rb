class AddScheduleDateToEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :schedule_date, :date
  end
end
