class ChangeZoneRates < ActiveRecord::Migration[5.0]
  def change
    remove_column :zone_rates, :vehicle_rates_id
    add_reference :zone_rates, :vehicle_rate
  end
end
