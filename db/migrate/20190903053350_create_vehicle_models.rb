class CreateVehicleModels < ActiveRecord::Migration[5.0]
  def change
    create_table :vehicle_models do |t|
      t.string :make_model
      t.integer :vehicle_category_id
      t.integer :capacity
      t.string :created_by
      t.string :updated_by

      t.timestamps
    end
  end
end
