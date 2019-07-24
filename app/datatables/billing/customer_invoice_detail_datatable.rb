class Billing::CustomerInvoiceDetailDatatable
  def initialize(trip_invoice)
    @trip_invoice = trip_invoice
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    @trip_data = get_data
    {
      "DT_RowId" => @invoice.id,
      id: @invoice.id,
      customer: @invoice_data['customer_name'],
      toll: @invoice_data['invoice_toll'],
      penalty: @invoice_data['invoice_penalty'],
      amount: @invoice_data['invoice_amount'],
      cgst: @invoice_data['cgst'],
      sgst: @invoice_data['sgst'],      
      status: @invoice.status,
      trip_data: 'NULL',
      date: @invoice.date.strftime("%m-%d-%Y")
    }
  end

  def check_is_guard
    is_guard = 0
    if @trip.trip_type == 0      
      is_guard = @trip.employee_trips.first.employee.is_guard ? 'Yes' : 'No'
    else
      is_guard = @trip.employee_trips.last.employee.is_guard ? 'Yes' : 'No'
    end
  end

  def get_data
    @trip_invoices = TripInvoice.where(:invoice_id => @invoice.id)
    invoice_amount = 0
    invoice_penalty = 0
    invoice_toll = 0
    @trip_invoices.each do |trip_invoice|
      invoice_amount = invoice_amount + trip_invoice.trip_amount
      invoice_penalty = invoice_penalty + trip_invoice.trip_penalty
      invoice_toll = invoice_toll + trip_invoice.trip_toll
    end

    {
      'customer_name' => @trip_invoices.first&.trip&.site&.employee_company&.name,
      'invoice_amount' => invoice_amount,
      'invoice_penalty' => invoice_penalty,
      'invoice_toll' => invoice_toll,
      'cgst' => @trip_invoices.first&.vehicle_rate&.cgst,
      'sgst' => @trip_invoices.first&.vehicle_rate&.sgst
    }
  end

end



