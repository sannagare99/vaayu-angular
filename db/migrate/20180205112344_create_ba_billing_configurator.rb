class CreateBaBillingConfigurator < ActiveRecord::Migration[5.0]
  def change
    create_table :ba_services do |t|
      t.belongs_to :business_associate
      t.string :service_type
      t.string :billing_model
      t.boolean :vary_with_vehicle, :default => false
    end
    
    create_table :ba_vehicle_rates do |t|
      t.belongs_to :ba_service
      t.integer :vehicle_capacity
      t.boolean :ac, :default => true
      t.decimal :cgst
      t.decimal :sgst
      t.boolean :overage, :default => false
      t.integer :time_on_duty
      t.decimal :overage_per_hour
    end

    create_table :ba_zone_rates do |t|
      t.belongs_to :ba_vehicle_rate
      t.decimal :rate
      t.decimal :guard_rate
      t.string :name
    end    

  end
end