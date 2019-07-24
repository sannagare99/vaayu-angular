class CreateZoneRates < ActiveRecord::Migration[5.0]
  def change
    create_table :zone_rates do |t|
      t.belongs_to :zone
      t.belongs_to :vehicle_rates
      t.decimal :rate
      t.decimal :guard_rate
    end    

    remove_reference :zones, :vehicle_rate
    remove_column :zones, :rate, :decimal
    remove_column :zones, :guard_rate, :decimal
  end
end