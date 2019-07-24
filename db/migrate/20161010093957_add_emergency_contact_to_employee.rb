class AddEmergencyContactToEmployee < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :emergency_contact_name, :string
    add_column :employees, :emergency_contact_phone, :string
  end
end
