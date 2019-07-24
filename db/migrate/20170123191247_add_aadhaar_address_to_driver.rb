class AddAadhaarAddressToDriver < ActiveRecord::Migration[5.0]
  def change
    add_column :drivers, :aadhaar_address, :string
  end
end
