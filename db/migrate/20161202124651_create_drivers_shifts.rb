class CreateDriversShifts < ActiveRecord::Migration[5.0]
  def change
    create_table :drivers_shifts do |t|

      t.belongs_to :driver
      t.belongs_to :vehicle
      t.datetime :start_time
      t.datetime :end_time
      t.integer :duration
      t.timestamps
    end
  end
end
