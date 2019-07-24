class NotificationsController < ApplicationController
  before_action :set_notification, only: [:archive, :move_driver_to_next_step]
  def index
    respond_to do |format|
      format.html
      format.json { render json: NotificationsDatatable.new(view_context, current_user)}
    end
  end

  def archive
    # TODO: check permission
    @notification.archive!
    respond_to do |format|
      format.json { render json: {}, status: :ok }
    end
  end

  def resolve
    # TODO: check permission
    @notification.update!(resolved_status: true)
    respond_to do |format|
      format.json { render json: {}, status: :ok }
    end
  end  

  # Mark all notifications as resolved 
  def mark_notifications_as_old
    case current_user.role
      when 'employer', 'transport_desk_manager'
        company = current_user.entity.employee_company.logistics_company
        @notification = Notification.joins(:driver).where(:receiver => [1,2], :status => 0, 'drivers.logistics_company_id' => company.id, :new_notification => true)
      when 'operator'
        company = current_user.entity.logistics_company
        @notification = Notification.joins(:driver).where(:receiver => [0,2], :status => 0, 'drivers.logistics_company_id' => company.id, :new_notification => true)
      when 'admin'
        @notification = Notification.where(:status => 0, :new_notification => true)
    end
    if @notification.any?
      @notification.each do |notification|
        notification.update!(new_notification: false)
      end
    end
  end

  def move_driver_to_next_step
    employee_trip = @notification.trip.employee_trips.where(:employee_id => @notification.employee.id).first
    @trip_route = employee_trip.trip_route
    trip_route_exception = @trip_route.trip_route_exceptions.where(:exception_type => :employee_no_show, :status => :open).first

    @trip = @notification.trip

    begin
      unless trip_route_exception.blank?
       trip_route_exception.resolved_by_operator!
       # Mark the notification as resolved
       #Create a notification for Notification resolved
       @prev_no_show_approved_notification = Notification.where(:trip => @trip, :driver => @trip.driver, :employee => @trip_route.employee, :message => 'employee_no_show_approved', :resolved_status => false).first

       if @prev_no_show_approved_notification.blank?
         reporter = "Approver: #{current_user.full_name}"
         @no_show_approved_notification = Notification.create!(:trip => @trip, :driver => @trip.driver, :employee => @trip_route.employee, :message => 'employee_no_show_approved', :resolved_status => false, :new_notification => true, :reporter => reporter)
         @no_show_approved_notification.send_notifications
         ResolveNotification.perform_at(Time.now + 10.minutes, @no_show_approved_notification.id)
       end         
       @notification.update!(resolved_status: true)
       render :json => {}
      end
    rescue
      render :json => { :errors => 'Something wrong' }
    end
  end

  private
  def set_notification
    @notification = Notification.find(params[:id])
  end

end
