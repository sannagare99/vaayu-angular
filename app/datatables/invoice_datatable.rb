class InvoiceDatatable
  def initialize(invoice = nil)
    @invoice = invoice
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{Invoice::DATATABLE_PREFIX}-#{@invoice.id}",
       :date => @invoice.date&.strftime("%m/%d/%Y").to_s,
       :id => @invoice.id,
       :status => @invoice.status,
       :trip_type => @invoice.company_type,
       :company => @invoice.company.name,
       :logistics_company => @invoice.company.logistics_company&.name,
       :start_date => @invoice.start_date.strftime("%m/%d/%Y").to_s,
       :end_date => @invoice.end_date.strftime("%m/%d/%Y").to_s,
       :trips_count => @invoice.trips_count,
       :amount => @invoice.amount,
       :invoice_url => invoice_url
    }
  end

  def invoice_url
    @invoice.invoice_attachments.blank? ? '#' : @invoice.invoice_attachments.first.file&.url&.to_s
  end
end
