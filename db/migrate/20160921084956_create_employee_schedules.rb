class CreateEmployeeSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_schedules do |t|

      t.belongs_to :employee
      t.integer :day
      t.time :check_in
      t.time :check_out

      t.timestamps
    end
  end
end
