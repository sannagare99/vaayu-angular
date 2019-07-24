class CreateShifts < ActiveRecord::Migration[5.0]
  def change
    create_table :shifts do |t|
      t.string :name
      t.string :start_time
      t.string :end_time
      t.string :status

      t.timestamps
    end
  end
end
