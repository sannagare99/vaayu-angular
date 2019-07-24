class Billing::CompletedTripDatatable
  def initialize(trip)
    @trip = trip
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      "DT_RowId" => @trip.id,
      id: @trip.id,
      date: @trip&.scheduled_date&.strftime("%m-%d-%Y"),
      customer: @trip&.site&.employee_company&.name,
      site: @trip&.site&.name,
      operator: @trip&.driver&.logistics_company&.name,
      business_associate: @trip&.driver&.business_associate&.legal_name,
      vehicle_type: @trip&.vehicle&.model,
      is_guard: is_guard,
      toll: @trip&.toll,
      penalty: @trip&.penalty,
      ba_toll: @trip&.ba_toll,
      ba_penalty: @trip&.ba_penalty,
      total_employees: @trip&.vehicle&.seats,
      served_employees: @trip&.employee_trips&.count,
      amount: @trip&.amount,
      ba_amount: @trip&.ba_amount
    }
  end

  def is_guard
    is_guard = 0
    if @trip.trip_type == 0      
      is_guard = @trip&.employee_trips&.first&.employee&.is_guard ? 'Yes' : 'No'
    else
      is_guard = @trip&.employee_trips&.last&.employee&.is_guard ? 'Yes' : 'No'
    end
  end

end



