class AddGenderFieldToDriver < ActiveRecord::Migration[5.0]
  def change
    add_column :drivers, :gender, :string
  end
end