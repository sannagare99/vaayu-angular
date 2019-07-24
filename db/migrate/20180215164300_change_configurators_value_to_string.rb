class ChangeConfiguratorsValueToString < ActiveRecord::Migration
  def up
    change_column :configurators, :value, :string
  end

  def down
    change_column :configurators, :value, :boolean
  end
end