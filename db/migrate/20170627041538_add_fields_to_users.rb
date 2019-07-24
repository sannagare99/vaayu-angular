class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :status, :integer
    add_column :users, :passcode, :string
    add_column :users, :invite_count, :integer, default: 0
    add_column :employees, :line_manager_id, :integer
  end
end
