class CreateTripChangeRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :trip_change_requests do |t|
      t.integer :request_type
      t.integer :reason
      t.integer :trip_type
      t.string :request_state
      t.datetime :new_date
      t.belongs_to :employee, foreign_key: true
      t.belongs_to :employee_trip

      t.timestamps
    end
  end
end
