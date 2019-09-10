class AddFNameLNameFieldToDriver < ActiveRecord::Migration[5.0]
  def change
  	add_column :drivers, :f_name, :string
  	add_column :drivers, :l_name, :string
  end
end
