class AddProcessCodeInEmployee < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :process_code, :string
  end
end
