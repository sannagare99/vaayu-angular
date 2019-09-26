class AddbussinessAeraToBa < ActiveRecord::Migration[5.0]
  def change
  	add_column :business_associates, :bussiness_area, :text, array: true
  end
end