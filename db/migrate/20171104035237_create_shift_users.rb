class CreateShiftUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :shift_users do |t|
      t.integer :shift_id
      t.integer :user_id

      t.timestamps
    end
  end
end
