class AddLogisticsCompanyToServices < ActiveRecord::Migration[5.0]
  def change    
    add_reference :services, :logistics_company
    add_reference :ba_services, :logistics_company
  end
end