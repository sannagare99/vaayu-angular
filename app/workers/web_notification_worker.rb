class WebNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3, :dead => false

  def perform(notification_id)
    @notification = Notification.where(:id => notification_id).first
    if @notification.blank?
      return
    end

    @notification.reload
    users = get_users
    users.each do |u|
      unless u.user.nil?
        unless (msg = get_message(u.user)).blank?
          ActionCable.server.broadcast(
              "notifications:notification_channel_for_#{u.user.hashed_id}",
              type: @notification.message,
              message: msg
          )
        end
      end
    end
  end

  # get operators and employers
  def get_users
    if @notification.driver.blank?
      ""
    else
      logistics_company = @notification.driver.logistics_company
      if @notification.trip.present?
        employee_company = @notification.trip.site.employee_company

        logistics_company.operators + employee_company.employers
      else
        logistics_company.operators
      end
    end
  end

  # get notifications message
  def get_message user
    if !user.blank? && !user.nil? && !user&.role.blank?
      slug = '.notification.receiver.' + user&.role&.to_s + '.' + @notification.message
      message = ''

      if @notification.receiver == user&.role&.to_s || @notification.receiver == 'both'
        message =
            I18n.t( slug,
                  :id => @notification.id,
                  :driver_name => @notification.driver_name,
                  :driver_licence => @notification.driver_licence,
                  :driver_plate => @notification.driver_plate,
                  :driver_phone => @notification.driver_phone,
                  :trip_number => @notification.trip_number,
                  :trip_url => @notification.trip_url,
                  :trip_id => @notification.trip_id,
                  :employee_name => @notification.employee_name,
                  :employee_phone => @notification.employee_phone
            )
      end
      message.html_safe
    end
  end

end
