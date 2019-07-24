class Billing::CustomerInvoiceDetailsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, invoice = nil)
    @view = view
    @invoice = invoice
  end

  def as_json(options = {})
    count = get_trip_invoices.length
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    @trip_invoices = get_trip_invoices
    @trip_invoices.map { |trip_invoice| Billing::CompletedTripDatatable.new(trip_invoice.trip).data }
  end

  def get_trip_invoices
    TripInvoice.where(:invoice_id => params[:invoice_id])
  end

end
