class Billing::BaInvoiceDatatable
  def initialize(invoice)
    @invoice = invoice
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    @invoice_data = get_data
    {
      "DT_RowId" => @invoice.id,
      id: @invoice.id,
      customer: @invoice_data['customer_name'],
      site: @invoice_data['site'],
      operator: @invoice_data['operator'],
      business_associate: @invoice_data['business_associate'],
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

  def get_data
    @trip_invoices = BaTripInvoice.where(:ba_invoice_id => @invoice.id)
    invoice_amount = 0
    invoice_penalty = 0
    invoice_toll = 0
    customer_name = @trip_invoices.first&.trip&.site&.employee_company&.name
    site = @trip_invoices.first&.trip&.site&.name
    operator = @trip_invoices.first&.trip&.driver&.logistics_company&.name
    business_associate = @trip_invoices.first&.trip&.driver&.business_associate&.legal_name
    @trip_invoices.each do |trip_invoice|
      invoice_amount = invoice_amount + trip_invoice.trip_amount
      invoice_penalty = invoice_penalty + trip_invoice.trip_penalty
      invoice_toll = invoice_toll + trip_invoice.trip_toll
    end
    if @trip_invoices.first&.trip_id.nil?
      trip = VehicleTripInvoice.where(:vehicle_id => @trip_invoices.first&.vehicle_id).where(:ba_trip_invoice_id => @trip_invoices&.first&.id).first&.trip
      customer_name = trip&.site&.employee_company&.name
      site = trip&.site&.name
      operator = trip&.driver&.logistics_company&.name
      business_associate = trip&.driver&.business_associate&.legal_name
    end

    {
      'customer_name' => customer_name,
      'site' => site,
      'operator' => operator,
      'business_associate' => business_associate,
      'invoice_amount' => invoice_amount,
      'invoice_penalty' => invoice_penalty,
      'invoice_toll' => invoice_toll,
      'cgst' => @trip_invoices.first&.ba_vehicle_rate&.cgst,
      'sgst' => @trip_invoices.first&.ba_vehicle_rate&.sgst
    }
  end

end



