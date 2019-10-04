class AddgstCertificatesDocUrlToBa < ActiveRecord::Migration[5.0]
  def change
  	add_column :business_associates, :gst_certificates_doc_url, :text
  end
end
