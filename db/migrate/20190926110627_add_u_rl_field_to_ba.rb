class AddURlFieldToBa < ActiveRecord::Migration[5.0]
  def change
  	add_column :business_associates, :cancelled_cheque_doc_url, :text
  	add_column :business_associates, :pan_card_doc_url, :text
  	add_column :business_associates, :msmed_certificate_doc_url, :text
  end
end
