class DropCompanyInvoices < ActiveRecord::Migration[5.0]
  def change
    drop_table :logistics_invoices
    drop_table :employer_invoices
  end
end
