class CreateComplianceNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :compliance_notifications do |t|
      t.integer :driver_id
      t.integer :vehicle_id
      t.string :message
      t.integer :status, default: 0
      t.integer :compliance_type

      t.timestamps
    end
  end
end
