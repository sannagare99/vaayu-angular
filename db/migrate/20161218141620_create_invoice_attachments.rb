class CreateInvoiceAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :invoice_attachments do |t|

      t.timestamps
      t.belongs_to :invoice
      t.attachment :file

    end
  end
end
