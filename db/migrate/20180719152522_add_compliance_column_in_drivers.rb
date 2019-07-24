class AddComplianceColumnInDrivers < ActiveRecord::Migration[5.0]
  def change
    add_column :drivers, :active_checklist_id, :integer
    add_column :drivers, :compliance_notification_message, :text
    add_column :drivers, :compliance_notification_type, :text
  end
end