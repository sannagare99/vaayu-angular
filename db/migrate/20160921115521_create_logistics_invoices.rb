class CreateLogisticsInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :logistics_invoices do |t|

      t.timestamps
    end
  end
end
