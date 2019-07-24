class AddOfflinePhoneToDriver < ActiveRecord::Migration[5.0]
  def change
    add_column :drivers, :offline_phone, :string
  end
end