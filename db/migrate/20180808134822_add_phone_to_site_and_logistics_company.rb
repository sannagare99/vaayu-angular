class AddPhoneToSiteAndLogisticsCompany < ActiveRecord::Migration[5.0]
  def change
  	add_column :sites, :phone, :text
    add_column :logistics_companies, :phone, :text
  end
end