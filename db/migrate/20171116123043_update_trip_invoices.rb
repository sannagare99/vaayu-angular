class UpdateTripInvoices < ActiveRecord::Migration[5.0]
  def change
    add_reference :trip_invoices, :vehicle_rate
    add_reference :trip_invoices, :zone_rate
  end
end