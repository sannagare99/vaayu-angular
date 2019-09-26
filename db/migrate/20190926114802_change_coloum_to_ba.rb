class ChangeColoumToBa < ActiveRecord::Migration[5.0]
   def change
   	remove_column :business_associates, :gstDocs
  end
end
