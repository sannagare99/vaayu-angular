class CreatePackageRates < ActiveRecord::Migration[5.0]
  def change
    create_table :package_rates do |t|
      t.belongs_to :vehicle_rate
      t.string :duration
      t.decimal :package_duty_hours, :default => 0
      t.decimal :package_km, :default => 0
      t.decimal :package_overage_per_km, :default => 0
      t.decimal :package_overage_per_time, :default => 0
      t.boolean :package_overage_time, :default => false
      t.decimal :package_rate, :default => 0
    end    

    create_table :ba_package_rates do |t|
      t.belongs_to :ba_vehicle_rate
      t.string :duration
      t.decimal :package_duty_hours, :default => 0
      t.decimal :package_km, :default => 0
      t.decimal :package_overage_per_km, :default => 0
      t.decimal :package_overage_per_time, :default => 0
      t.boolean :package_overage_time, :default => false
      t.decimal :package_rate, :default => 0
    end    

    add_reference :trip_invoices, :package_rate
    add_reference :ba_trip_invoices, :ba_package_rate

    add_column :package_rates, :package_mileage_calculation, :string
    add_column :ba_package_rates, :package_mileage_calculation, :string
    
  end
end