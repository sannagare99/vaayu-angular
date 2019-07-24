class AddDeviseTokenAuthToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :tokens, :text
    add_column :users, :provider, :string, null: false, default: 'email'
    add_column :users, :uid, :string, null: false, default: ''
  end
end
