class CreateBusTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :bus_trips do |t|

      t.string :status
      t.string :route_name

      t.timestamps
    end
  end
end