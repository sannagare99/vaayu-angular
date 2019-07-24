class CreateChecklists < ActiveRecord::Migration[5.0]
  def change
    create_table :checklists do |t|
      t.integer :vehicle_id
      t.integer :driver_id
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
