class CreateTripRouteExceptions < ActiveRecord::Migration[5.0]
  def change
    create_table :trip_route_exceptions do |t|
      t.integer :trip_route_id
      t.datetime :date
      t.integer :exception_type
      t.string :status
    end
  end
end
