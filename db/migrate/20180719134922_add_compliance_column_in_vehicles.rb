class AddComplianceColumnInVehicles < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicles, :active_checklist_id, :integer
    add_column :vehicles, :compliance_notification_message, :text
    add_column :vehicles, :compliance_notification_type, :text
  end
end