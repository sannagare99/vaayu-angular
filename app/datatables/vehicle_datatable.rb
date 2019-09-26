class VehicleDatatable
  def initialize(vehicle = nil)
    @vehicle = vehicle
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    vehicle_model = @vehicle.make.present? ? @vehicle.make : ''
    {
        "DT_RowId" => "#{Vehicle::DATATABLE_PREFIX}-#{@vehicle.id}",
        :id => @vehicle.id,
        :name => @vehicle.colour + ' ' + vehicle_model + ' ' + @vehicle.model  ,
        :plate_number => @vehicle.plate_number,
        :ba => @vehicle.business_associate&.name,
        :driver => get_driver,
        :insurance_date => @vehicle.insurance_date,
        :make => @vehicle.make,
        :model => @vehicle.model,
        :colour => @vehicle.colour,
        :seats => @vehicle.seats,
        :odometer => @vehicle.odometer,
        :checklist_attributes => { id: @vehicle&.active_checklist_id, status: checklist_status[:title], notification_type: checklist_status[:notification] },
        :status => @vehicle.status,
        :driver_request => driver_request
    }
  end

  def driver_request
    case @vehicle.status
    when 'vehicle_ok'
      @driver_request = ''
    when 'vehicle_ok_pending'
      @driver_request = DriverRequest.where(:vehicle => @vehicle).where(:request_state => [:cancel]).order('id desc').first
    when 'vehicle_broke_down'
      @driver_request = DriverRequest.where(:vehicle => @vehicle).where(:request_state => [:approved]).order('id desc').first
    when 'vehicle_broke_down_pending'
      @driver_request = DriverRequest.where(:vehicle => @vehicle).where(:request_state => [:pending]).order('id desc').first
    end

    @driver_request
  end

  def get_driver
    driver = ''
    unless @vehicle.driver.blank?
      driver = @vehicle.driver&.f_name + ' ' + @vehicle.driver&.l_name
    end
  end

  def checklist_status
    {title: @vehicle.compliance_notification_message, notification: @vehicle.compliance_notification_type}
  end

  def formatted_date(date)
    date = date.in_time_zone('Chennai')
    if date > Time.now.in_time_zone('Chennai').beginning_of_day
      "Today"
    elsif date > Time.now.in_time_zone('Chennai').beginning_of_day - 1.day
      "Yesterday"
    else
      date.strftime("%B %d, %Y")
    end
  end

end