class CreateClusterVehicles < ActiveRecord::Migration[5.0]
  def change
    create_table :cluster_vehicles do |t|
      t.datetime :date
      t.references :vehicle
      t.references :employee_cluster

      t.timestamps
    end
  end
end
