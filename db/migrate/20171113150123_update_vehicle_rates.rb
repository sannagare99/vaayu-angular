class UpdateVehicleRates < ActiveRecord::Migration[5.0]
  def change
    remove_column :vehicle_rates, :rate_per_trip, :decimal
    remove_column :vehicle_rates, :default_rate, :decimal
    remove_column :vehicle_rates, :guard_rate, :decimal
	remove_column :vehicle_rates, :penalty, :decimal

	change_column :vehicle_rates, :cgst, :decimal, default: 0
	change_column :vehicle_rates, :sgst, :decimal, default: 0
	change_column :vehicle_rates, :time_on_duty, :decimal, default: 0
	change_column :vehicle_rates, :overage_per_hour, :decimal, default: 0
	
	change_column :zone_rates, :rate, :decimal, default: 0
	change_column :zone_rates, :guard_rate, :decimal, default: 0
  end
end