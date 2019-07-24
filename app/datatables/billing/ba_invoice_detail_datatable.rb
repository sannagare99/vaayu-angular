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
      vehicle_number: @data_item[1]['plate_number'],
      vehicle_type: @data_item[1]['vehicle_type'],
      zone: @data_item[1]['zone_name'],
      total_trips: @data_item[1]['total_trips'],
      guard_trips: @data_item[1]['guard_trips'],
      rate: @data_item[1]['rate'],
      guard_rate: @data_item[1]['guard_rate'],
      toll: @data_item[1]['toll'],
      amount: @data_item[1]['amount']
    }
  end

end



