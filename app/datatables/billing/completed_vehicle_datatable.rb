class Billing::CompletedVehicleDatatable
  def initialize(vehicle)
    @vehicle = vehicle
    puts @vehicle
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      "DT_RowId" => @vehicle[:vehicle_id],
      period: @vehicle[:period],
      customer: @vehicle[:customer],
      site: @vehicle[:site],
      operator: @vehicle[:operator],
      business_associate: @vehicle[:business_associate],
      vehicle_number: @vehicle[:vehicle_number],
      vehicle_type: @vehicle[:vehicle_type].to_s + ' Seater',
      hours_on_duty: @vehicle[:hours_on_duty],
      mileage_on_duty: @vehicle[:mileage_on_duty],
      total_trips: @vehicle[:total_trips],
      hours_on_trips: @vehicle[:hours_on_trips],
      mileage_on_trips: @vehicle[:mileage_on_trips],
      trips: @vehicle[:trips]
    }
  end

end



