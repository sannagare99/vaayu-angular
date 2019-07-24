class CreateTripRoutes < ActiveRecord::Migration[5.0]
  def change
    create_table :trip_routes do |t|
      t.integer :duration
      t.integer :distance
      t.integer :route_order
      t.text :start_location
      t.text :end_location
      t.belongs_to :employee_trip, foreign_key: true
      t.belongs_to :trip, foreign_key: true
    end

    add_reference :employee_trips, :trip_route, index: true
  end
end
