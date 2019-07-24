class Reports::ReportPanicAlarmDatatable
  include ReportsHelper
  def initialize(exception = nil)
    @exception = exception
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       :date => @exception.date.strftime("%m/%d/%Y %H:%M"),
       :manifest_id => manifest_id,
       :driver => driver,
       :vehicle => vehicle,
       :employee_id => @exception.trip_route.employee.employee_id,
       :alarm_time => @exception.date.strftime("%m/%d/%Y %H:%M"),
       :location => '',
       :resolution_time => @exception.resolved_date.strftime("%m/%d/%Y %H:%M"),
       :resolved_by => 'Operator',
    }
  end

  private

  def manifest_id
    if @exception.trip_route.present?
      if @exception.trip_route.trip.present?
        return "#{@exception.trip_route.trip.start_date&.strftime("%m/%d/%Y")} - #{@exception.trip_route.trip.id}"        
      end
    end

    ''
  end

  def driver
    if @exception.trip_route.present?
      if @exception.trip_route.trip.present?
        if @exception.trip_route.trip.driver.present?
          return @exception.trip_route.trip.driver.full_name          
        end
      end
    end
    ''
  end

  def vehicle
    if @exception.trip_route.present?
      if @exception.trip_route.trip.present?
        if @exception.trip_route.trip.vehicle.present?
          return @exception.trip_route.trip.vehicle.plate_number          
        end
      end
    end
    ''    
  end

  def get_trip
    @exception.trip_route.trip
  end
end



