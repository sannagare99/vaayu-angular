class CreateDriverRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :driver_requests do |t|
      t.integer :request_type
      t.integer :reason
      t.integer :trip_type
      t.string :request_state
      t.datetime :request_date
      t.datetime :start_date
      t.datetime :end_date
      t.belongs_to :driver, foreign_key: true

      t.timestamps
    end
  end
end