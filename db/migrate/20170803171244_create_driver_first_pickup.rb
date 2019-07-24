class CreateDriverFirstPickup < ActiveRecord::Migration[5.0]
  def change
    create_table :driver_first_pickups do |t|
      t.belongs_to :trip
      t.belongs_to :driver
      t.integer :pickup_time
      t.datetime :time
      
      t.timestamps
    end
  end
end