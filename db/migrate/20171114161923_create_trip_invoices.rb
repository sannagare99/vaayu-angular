class CreateTripInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :trip_invoices do |t|
      t.belongs_to :trip
      t.belongs_to :invoice
      t.decimal :trip_amount, default: 0
      t.decimal :trip_penalty, default: 0
      t.decimal :trip_toll, default: 0
    end
  end
end