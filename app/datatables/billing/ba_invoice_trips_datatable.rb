class Billing::BaInvoiceTripsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view = nil, invoice = nil)
    @view = view
    @invoice = invoice
    @billing_model = nil
  end

  def as_json(options = {})
    count = get_trip_invoices.length
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data,
        billing_model: @billing_model
    }
  end

  private

  def data
    @trip_invoices_data = get_trip_invoices    
    if @trip_invoices_data[:trips].nil?
      @trip_invoices_data[:trip_invoices].map { |trip_invoice| Billing::BaInvoiceTripDatatable.new(trip_invoice.trip).data }
    else
      @trip_invoices_data[:trips].map { |vehicle_trip_invoice| Billing::BaInvoiceTripDatatable.new(vehicle_trip_invoice.trip).data }
    end
  end

  def get_trip_invoices
    trip_invoices = BaTripInvoice.where(:ba_invoice_id => @invoice.id)
    trips = nil
    trip_invoices.each do |trip_invoice|
      if trip_invoice.trip_id.nil?
        @billing_model = 'Package Rates'
        trips = VehicleTripInvoice.where(:vehicle_id => trip_invoice.vehicle_id, :ba_trip_invoice_id => trip_invoice.id)
      end
    end
    {
      'trip_invoices': trip_invoices,
      'trips': trips
    }    
  end

end
