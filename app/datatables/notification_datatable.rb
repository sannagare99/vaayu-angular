class NotificationDatatable
  def initialize(notifications = nil, user = nil, badge_count)
    @notifications = notifications
    @user = user
    @badge_count = badge_count
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    @notifications_data = notifications_data
    {
       "DT_RowId" => "#{Notification::DATATABLE_PREFIX}-#{@notifications_data[:first_notification].trip_id}",
       :roster_name => @notifications_data[:roster_name],
       :date => @notifications_data[:first_notification].created_at.strftime("%d/%m/%Y"),
       :id => @notifications_data[:first_notification].id,
       :created_at => @notifications_data[:first_notification].created_at.strftime("%d/%m/%Y  %I:%M%p"),
       :display_message => I18n.t('notification.message.' + @notifications_data[:first_notification].message, 
        employee_name: @notifications_data[:first_notification].employee_name, 
        site_name: @notifications_data[:first_notification]&.trip&.site&.name, 
        driver_name: @notifications_data[:first_notification].driver_name,
        notification_remarks: @notifications_data[:first_notification]&.get_remarks,
        employee_id: @notifications_data[:first_notification]&.employee_company_id),
       :message => @notifications_data[:first_notification].message,
       :trip_number => @notifications_data[:first_notification].trip_number,
       :trip_url => @notifications_data[:first_notification].trip_url,
       :trip_id => @notifications_data[:first_notification].trip_id,
       :driver_id => @notifications_data[:first_notification].driver_id,

       :driver_request_id => @notifications_data[:first_notification].driver_request_id,

       :driver_name => @notifications_data[:first_notification].driver_name,
       :driver_phone => @notifications_data[:first_notification].driver_phone,
       :driver_licence => @notifications_data[:first_notification].driver_licence,
       :driver_plate => @notifications_data[:first_notification].driver_plate,

       :employee_name => @notifications_data[:first_notification].employee_name,
       :employee_phone => @notifications_data[:first_notification].employee_phone,
       :move_driver_to_next_step => "",
       :resolved_status => @notifications_data[:first_notification].resolved_status,
       :last_notification => @notifications_data[:last_notification],
       :role => @user.role,
       :badge_count => @badge_count,
       :reporter => @notifications_data[:first_notification]&.reporter
       #:trip_route => @notifications_data[:trip_route],
       #:trip => @notifications_data[:trip]
    }
  end
  
  private
  def notifications_data
    @first_notification = @notifications.shift

    @last_notification = @notifications
    #@trip = Trip.where(id: @notifications[:trip_id]).first

    @direction = @first_notification&.trip&.trip_type == 'check_in' ? 'IN' : 'OUT'
    @roster_name = "#{@first_notification&.trip&.scheduled_date&.strftime('%d/%m').to_s} #{@direction} #{@first_notification&.trip&.employee_trips&.first&.date&.strftime('%H:%M').to_s} #{@first_notification&.trip&.id&.to_s}"

    # @last_notification = @last_unresolved_notification + @last_resolved_notification

    
    notification_arr = []
    if @last_notification.present?
      @last_notification.map do |notification|
        notification_arr.push(notification&.get_info)
      end
    end

    @notification_data = {
      :first_notification => @first_notification,
      :last_notification => notification_arr,
      :roster_name => @roster_name
      #:trip => trip_data(@trip)
    }
  end

  def move_driver_to_next_step
    move_driver_to_next_step_link = ''
    if @notification.message == 'employee_no_show'
      employee_trip = @notification.trip.employee_trips.where(:employee_id => @notification.employee_id).first
      begin
        trip_route = employee_trip.trip_route
        trip_route_exception = trip_route.trip_route_exceptions.where(:exception_type => :employee_no_show, :status => :open).first

        if !trip_route_exception.blank? && trip_route_exception.open?
          move_driver_to_next_step_link = "/notifications/#{@notification.id}/move_driver_to_next_step"
        end
      rescue
        move_driver_to_next_step_link = ''
      end

    end
    move_driver_to_next_step_link
  end

  def trip_data(trip)
    {
       "DT_RowId" => "#{Trip::DATATABLE_PREFIX}-#{trip.id}",
       :status => trip.status,
       :date => trip.scheduled_date&.strftime("%d/%m/%Y").to_s,
       :id => trip.id,
       :trip_type => trip.trip_type,
       :start_date => trip.start_date,
       :approximate_duration => trip.scheduled_approximate_duration.minutes,
       :approximate_distance => trip.scheduled_approximate_distance / 1000,
       :driver_name => trip&.driver&.f_name.to_s,
       :driver_l_name => trip&.driver&.l_name.to_s,
       :licence => trip&.driver&.licence_number.to_s,
       :plate_number => trip&.vehicle&.plate_number.to_s,
       :trip_routes => emloyee_status(trip),
       :site_lat => trip.employee_trips.first&.employee&.site&.latitude,
       :site_lng => trip.employee_trips.first&.employee&.site&.longitude,
       :cancel_status => trip.cancel_status,
       :completed_date => trip.completed_date&.strftime("%I:%M%p").to_s,
       :scheduled_end_date => trip.approximate_trip_end_date&.strftime("%I:%M%p").to_s,
       :direction => trip.trip_type.humanize,
       :is_guard_required => is_guard_required(trip)
    }
  end

  def is_guard_required(trip)
    begin
      trip.is_guard_required?
    rescue
      false
    end
  end

  def is_first_female_pickup(trip)
    begin
      trip.check_in? && @trip.trip_routes.order("scheduled_route_order").first.employee&.gender == "female"
    rescue
      false
    end
  end

  def is_last_female_drop(trip)
    begin
      trip.check_out? && @trip.trip_routes.order("scheduled_route_order").last.employee&.gender == "female"
    rescue
      false
    end
  end

  def emloyee_status(trip)
    employee_trips = EmployeeTrip.joins(:trip_route).where(:trip => trip).order('trip_routes.scheduled_route_order ASC')
    employee_trips.map do |employee_trip|
      employee_trip.trip_route&.get_employee_info
    end
  end  
end
