class InvoiceAttachment < ApplicationRecord

  belongs_to :invoice
  has_attached_file :file, :s3_headers => {"Content-Type" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"}

  # Validate content type
  validates_attachment_content_type :file,
                                    :content_type => /^.+/,
                                    :message => 'only (xls, xlsx, csv) files'


end
