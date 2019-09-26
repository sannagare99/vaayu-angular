class AddgstDocsFieldToBa < ActiveRecord::Migration[5.0]
  def change
  	add_column :business_associates, :gstDocs, :text
  end
end