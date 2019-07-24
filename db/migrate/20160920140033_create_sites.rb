class CreateSites < ActiveRecord::Migration[5.0]
  def change
    create_table :sites do |t|

      t.string :name
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.belongs_to :employee_company

      t.timestamps
    end
  end
end