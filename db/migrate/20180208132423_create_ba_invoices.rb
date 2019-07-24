class CreateBaInvoices < ActiveRecord::Migration[5.0]
  def change
  	create_table :ba_invoices do |t|
      t.references :company, :polymorphic => true
      t.datetime :date
      t.datetime :start_date
      t.datetime :end_date
      t.integer :trips_count
      t.decimal :amount, precision: 12, scale: 2
      t.string :status
      t.timestamps
    end

    create_table :ba_trip_invoices do |t|
      t.belongs_to :trip
      t.belongs_to :ba_invoice
      t.decimal :trip_amount, default: 0
      t.decimal :trip_penalty, default: 0
      t.decimal :trip_toll, default: 0
      t.belongs_to :ba_vehicle_rate
      t.belongs_to :ba_zone_rate
    end
  end
end