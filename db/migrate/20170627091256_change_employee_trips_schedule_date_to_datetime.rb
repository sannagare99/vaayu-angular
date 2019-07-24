class ChangeEmployeeTripsScheduleDateToDatetime < ActiveRecord::Migration
  def up
    change_column :employee_trips, :schedule_date, :datetime
  end

  def down
    change_column :employee_trips, :schedule_date, :date
  end
end