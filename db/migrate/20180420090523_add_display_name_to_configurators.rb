class AddDisplayNameToConfigurators < ActiveRecord::Migration[5.0]
  def change
    add_column :configurators, :display_name, :string
    add_column :configurators, :options, :text
  end
end
