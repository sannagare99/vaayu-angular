require 'geohash'

namespace :driver do

  desc 'Set Driver Sort Option'
  task :set_sort_status => [:environment] do
    drivers = Driver.all
  	drivers.each do |driver|

  	  status = -1
      if driver.status == 'on_leave'
        status = 0  
      end

      notification = driver.compliance_notifications.active.order(updated_at: :desc).first
      # This notification to be shown below any car broke down or leave notification
      if notification.present?
        notification.checklist? ? status = 1 : status = 2
      end

      driver_request = DriverRequest.where(:driver => driver).where('start_date > ?', Time.now).where(:request_state => [:cancel, :pending]).first
      if driver_request.present?
        status = 3
      end

      driver.update!(sort_status: status)	
  	end
  end

  desc 'Set Driver Compliance Message'
  task :set_compliance_messages => [:environment] do
    drivers = Driver.all
    drivers.each do |driver|
      @active_checklist = driver.checklists.active.first
      status = {title: ""}

      if @active_checklist.present?
        items = @active_checklist.checklist_items  
        notification = driver.compliance_notifications.active.order(updated_at: :desc).first
        if notification.present?
          status = {title: notification.get_message, notification: "#{notification.checklist? ? 'checklist' : 'provisioning'}"}
        elsif !items.map(&:value).uniq.compact.blank?
          @date = items.order(updated_at: :desc).first.updated_at
          status = {title: "In Progress (#{formatted_date(@date)})"}
        elsif items.map(&:value).uniq.compact.blank?
          items.map(&:value).uniq.compact.blank?
          status = {title: "Verify"}
        end
      elsif driver.checklists.completed.present?
        @date = driver.checklists.completed.order(updated_at: :desc).first.updated_at
        status = {title: "All Good (#{formatted_date(@date)})"}
      end

      active_checklist_id = 0
      notification_status = ''
      notification_type = ''

      if @active_checklist.present?
        active_checklist_id = @active_checklist&.id
      end

      notification_status = status[:title]
      if status[:notification].present?
        notification_type = status[:notification]
      end

      driver.update!(active_checklist_id: active_checklist_id, 
        compliance_notification_message: notification_status,
        compliance_notification_type: notification_type)
    end
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
