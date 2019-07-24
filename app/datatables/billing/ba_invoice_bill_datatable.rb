class Billing::BaInvoiceBillDatatable
  def initialize(data_item)
    @data_item = data_item
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      "DT_RowId" => @data_item[0],
      customer: @data_item[1]['customer'],
      site: @data_item[1]['site'],
      operator: @data_item[1]['operator'],
      business_associate: @data_item[1]['business_associate'],
      vehicle_number: @data_item[1]['plate_number'],
      vehicle_type: @data_item[1]['vehicle_type'],
      zone: @data_item[1]['zone_name'],
      total_trips: @data_item[1]['total_trips'],
      guard_trips: @data_item[1]['guard_trips'],
      rate: @data_item[1]['rate'],
      guard_rate: @data_item[1]['guard_rate'],
      hours_on_duty: @data_item[1]['hours_on_duty'],
      mileage_on_duty: @data_item[1]['mileage_on_duty'],
      hours_on_trips: @data_item[1]['hours_on_trips'],
      mileage_on_trips: @data_item[1]['mileage_on_trips'],
      toll: @data_item[1]['toll'],
      amount: @data_item[1]['amount']
    }
  end

end



