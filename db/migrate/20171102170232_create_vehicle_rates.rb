class CreateVehicleRates < ActiveRecord::Migration[5.0]
  def change
    create_table :services do |t|
      t.belongs_to :site
      t.string :service_type
      t.string :billing_model
      t.boolean :vary_with_vehicle, :default => false
    end
    
    create_table :vehicle_rates do |t|
      t.belongs_to :service
      t.integer :vehicle_capacity
      t.boolean :ac, :default => true
      t.decimal :rate_per_trip
      t.decimal :default_rate
      t.decimal :guard_rate
      t.decimal :cgst
      t.decimal :sgst
      t.decimal :penalty
      t.boolean :overage, :default => false
      t.integer :time_on_duty
      t.decimal :overage_per_hour
    end

    add_reference :zones, :site
    add_reference :zones, :vehicle_rate
    add_column :zones, :rate, :decimal
    add_column :zones, :guard_rate, :decimal
  end
end