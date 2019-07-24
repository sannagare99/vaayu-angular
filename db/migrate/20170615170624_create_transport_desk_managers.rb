class CreateTransportDeskManagers < ActiveRecord::Migration[5.0]
  def change
    create_table :transport_desk_managers do |t|

      t.belongs_to :employee_company

      t.timestamps
    end
  end
end