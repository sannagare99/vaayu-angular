class AddFieldToDriver < ActiveRecord::Migration[5.0]
  def change
    add_column :drivers, :blacklisted, :boolean, default: false rescue nil
    add_column :drivers, :driver_name, :string rescue nil
    add_column :drivers, :date_of_birth, :datetime rescue nil
    add_column :drivers, :father_spouse_name, :string rescue nil
 	end
end
