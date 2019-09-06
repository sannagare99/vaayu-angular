class CreateVehicleCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :vehicle_categories do |t|
      t.string :category_name
      t.string :created_by
      t.string :updated_by

      t.timestamps
    end
  end
end
