class CreateEmployeeClusters < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_clusters do |t|
      t.string :error
      t.datetime :date

      t.references :driver

      t.timestamps
    end
  end
end
