class CreateConfigurator < ActiveRecord::Migration[5.0]
  def change
    create_table :configurators do |t|
      t.string :request_type
      t.boolean :value, default: false
    end
  end
end