class AddFieldToDriver < ActiveRecord::Migration[5.0]
  def change
    add_column :drivers, :blacklisted, :boolean, default: false
    add_column :drivers, :driver_name, :string
    add_column :drivers, :date_of_birth, :datetime
    add_column :drivers, :father_spouse_name, :string
 	end
end
