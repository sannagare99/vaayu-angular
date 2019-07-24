class CreateLogisticsCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :logistics_companies do |t|
      t.string :name

      t.timestamps
    end
  end
end
