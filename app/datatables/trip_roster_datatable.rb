class TripRosterDatatable
  def initialize(trip = nil, user = nil)
    @trip = trip
    @user = user
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{Trip::DATATABLE_PREFIX}-#{@trip.id}",
       :status => @trip.status,
       :date => @trip&.employee_trips&.first&.date&.strftime("%d/%m").to_s,
       :scheduled_date => @trip&.employee_trips&.first&.date&.strftime("%H:%M").to_s,
       :id => @trip.id,
       :trip_type => @trip.trip_type,
       :start_date => @trip.start_date,
       :approximate_duration => @trip.scheduled_approximate_duration.minutes,
       :approximate_distance => @trip.scheduled_approximate_distance / 1000,
       :driver_name => @trip&.driver&.f_name.to_s,
       :driver_l_name => @trip&.driver&.l_name.to_s,
       :licence => @trip&.driver&.licence_number.to_s,
       :plate_number => @trip&.vehicle&.plate_number.to_s,
       # :trip_routes => emloyee_status,
       :site_lat => @trip.employee_trips.first&.employee&.site&.latitude,
       :site_lng => @trip.employee_trips.first&.employee&.site&.longitude,
       :cancel_status => @trip.cancel_status,
       :completed_date => @trip.completed_date&.strftime("%I:%M%p").to_s,
       :scheduled_end_date => @trip.approximate_trip_end_date&.strftime("%I:%M%p").to_s,
       :shift => shift,
       :direction => direction,
       # :is_first_female_pickup => is_first_female_pickup,
       # :is_last_female_drop => is_last_female_drop,
       :planned_passengers => employee_trips_count,
       :actual_passengers => actual_passengers,
       :driver_phone => @trip&.driver&.phone,
       :role => @user.role,
       :is_guard_required => is_guard_required && @trip.created?,
       :area => area
    }
  end

  private

  def employee_trips_count
    count = 0
    @trip.employee_trips.each do |et|
      count += 1
    end

    count
  end

  def is_guard_required
    begin
      @trip.is_guard_required?
    rescue
      false
    end
  end

  def actual_passengers
    count = '--'
    if @trip.active? || @trip.canceled? || @trip.completed?
      count = 0
      @trip.trip_routes.each do |tr|
        count += 1
        if tr.missed? || tr.canceled?
          count -= 1
        end
      end
    end

    count
  end

  def direction
    begin
      if @trip.trip_type == 'check_in'
        "IN"
      else
        "OUT"
      end
    rescue
      ""
    end
  end

  def shift
    begin
      @trip.employee_trips.first&.date.strftime("%H:%M").to_s
    rescue
      ""
    end
  end

  def is_first_female_pickup
    begin
      @trip.check_in? && @trip.trip_routes.first.employee&.gender == "female"
    rescue
      false
    end
  end

  def is_last_female_drop
    begin
      @trip.check_out? && @trip.trip_routes.last.employee&.gender == "female"
    rescue
      false
    end
  end

  def emloyee_status
    employee_trips = @trip.employee_trips.sort_by { |et| et&.trip_route&.scheduled_route_order || 0 }
    #employee_trips = EmployeeTrip.joins(:trip_route).where(:trip => @trip).order('trip_routes.scheduled_route_order ASC')
    employee_trips.map do |employee_trip|
      employee_trip.trip_route&.get_employee_info
    end
  end

  def area
    #Show area of first employee is case of login and last employee in case of log out
    if @trip.check_in?
      if @trip.trip_routes.first&.employee&.is_guard?
        area_landmark = @trip.trip_routes[1]&.employee&.landmark
      else
        area_landmark = @trip.trip_routes.first&.employee&.landmark
      end      
    else
      if @trip.trip_routes.last&.employee&.is_guard?
        area_landmark = @trip.trip_routes[-2]&.employee&.landmark
      else
        area_landmark = @trip.trip_routes.last&.employee&.landmark
      end      
    end

    if area_landmark.blank?
      area_landmark = "--"
    end
    area_landmark
  end
end
