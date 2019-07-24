class CreateShiftTimes < ActiveRecord::Migration[5.0]
  def change
    create_table :shift_times do |t|
      t.integer :shift_manager_id
      t.integer :site_id
      t.integer :shift_type
      t.datetime :date
      t.datetime :schedule_date
      t.string :type

      t.timestamps
    end
  end
end
