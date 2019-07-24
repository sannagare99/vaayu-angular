class CreateEmployerInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :employer_invoices do |t|

      t.belongs_to :employee_company
      t.belongs_to :trip

      t.timestamps
    end
  end
end
