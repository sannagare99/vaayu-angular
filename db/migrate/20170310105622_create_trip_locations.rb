class CreateTripLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :trip_locations do |t|
      t.belongs_to :trip
      t.text :location
      t.datetime :time
      
      t.timestamps
    end
  end
end
