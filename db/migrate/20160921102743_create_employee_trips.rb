class CreateEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_trips do |t|

      t.belongs_to :employee
      t.belongs_to :trip

      t.datetime :date
      t.integer :trip_type
      t.string :status

      t.integer :employee_schedule_id
      
      t.timestamps
    end
  end
end