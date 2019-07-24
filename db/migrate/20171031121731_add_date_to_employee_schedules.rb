class AddDateToEmployeeSchedules < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_schedules, :date, :datetime
  end
end
