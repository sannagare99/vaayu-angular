class AddConfTypeToConfigurators < ActiveRecord::Migration[5.0]
  def change
    add_column :configurators, :conf_type, :integer, default: 0
  end
end
