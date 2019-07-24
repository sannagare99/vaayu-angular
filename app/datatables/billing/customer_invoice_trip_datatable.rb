class Billing::CustomerInvoiceTripDatatable
  def initialize(trip)
    @trip = trip
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    @trip_data = get_data
    {
      "DT_RowId" => @trip.id,      
      id: @trip.id,
      date: @trip.scheduled_date.strftime("%m-%d-%Y"),
      customer: @trip&.site&.employee_company&.name,
      site: @trip.site&.name,
      operator: @trip.driver&.logistics_company&.name,
      business_associate: @trip.vehicle&.business_associate&.legal_name,
      tripsheet: @trip.id,
      trip_type: @trip_data['trip_type'],      
      shift_time: @trip.employee_trips.first.schedule_date.strftime("%H:%M"),
      reporting_time: @trip_data['reporting_time'],
      actual_time: @trip_data['actual_time'],      
      vehicle_no: @trip.vehicle&.plate_number,
      vehicle_type: @trip.vehicle&.model,
      seating_capacity: @trip.vehicle&.seats,
      driver: @trip.driver&.f_name + ' ' + @trip.driver&.l_name,
      planned_employees: @trip.employee_trips&.count,
      actual_employees: @trip_data['actual_employees'],      
      guard: @trip_data['is_guard'],
      gps: 'Y',
      planned_mileage: @trip.planned_approximate_distance,
      planned_duration: @trip_data['planned_approximate_duration'],
      actual_mileage: @trip.actual_mileage,
      actual_duration: @trip_data['actual_duration']
    }
  end

  def get_data
    is_guard = 0
    trip_type = 'Pick-Up'
    reporting_time = ''
    actual_time = ''
    if @trip.trip_type == 'check_in'      
      is_guard = @trip.employee_trips.first.employee.is_guard ? 'Y' : 'N'
      trip_type = 'Pick-Up'
      reporting_time = @trip.employee_trips.minimum(:date).strftime("%H:%M")
      actual_time = @trip&.employee_trips&.last&.trip_route&.completed_date&.strftime("%H:%M")
    else
      is_guard = @trip.employee_trips.last.employee.is_guard ? 'Y' : 'N'
      trip_type = 'Drop'
      reporting_time = @trip&.employee_trips&.maximum(:date)&.strftime("%H:%M")
      actual_time = @trip&.employee_trips&.last&.trip_route&.on_board_date&.strftime("%H:%M")
    end
    actual_employees = EmployeeTrip.where(:trip_id => @trip.id).where(:status => 'completed').count
    planned_approximate_duration = (@trip.planned_approximate_duration.to_i / 60).to_s + 'h ' + (@trip.planned_approximate_duration.to_i % 60).to_s + 'min'
    actual_duration = ((@trip.real_duration.to_i / 60).to_i).to_s + 'h ' + ((@trip.real_duration.to_i % 60).to_i).to_s + 'min'

    {
      'is_guard' => is_guard,
      'trip_type' => trip_type,
      'actual_employees' => actual_employees,
      'reporting_time' => reporting_time,
      'actual_time' => actual_time,
      'planned_approximate_duration' => planned_approximate_duration,
      'actual_duration' => actual_duration
    }
  end
end



