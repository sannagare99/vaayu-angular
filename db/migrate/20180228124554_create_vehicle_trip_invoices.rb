class CreateVehicleTripInvoices < ActiveRecord::Migration[5.0]
  def change
    add_reference :trip_invoices, :vehicle
    add_reference :ba_trip_invoices, :vehicle

    create_table :vehicle_trip_invoices do |t|
      t.belongs_to :trip
      t.belongs_to :trip_invoice
      t.belongs_to :vehicle      
      t.belongs_to :ba_trip_invoice
    end   	
  end

end
