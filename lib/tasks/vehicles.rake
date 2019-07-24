require 'geohash'

namespace :vehicle do

  desc 'Set Vehicle Sort Option'
  task :set_sort_status => [:environment] do
    vehicles = Vehicle.all
  	vehicles.each do |vehicle|

      status = -1
      
      notification = vehicle.compliance_notifications.active.order(updated_at: :desc).first
      # This notification to be shown below any car broke down or leave notification
      if notification.present?
        notification.checklist? ? status = 1 : status = 2
      end

      case vehicle.status
      when 'vehicle_ok_pending'
        status = 3
      when 'vehicle_broke_down_pending'
        status = 4
      when 'vehicle_broke_down'
        status = 0        
      end

      vehicle.update!(sort_status: status)	
  	end
  end

  desc 'Set Vehicle Compliance Message'
  task :set_compliance_messages => [:environment] do
    vehicles = Vehicle.all
    vehicles.each do |vehicle|
      @active_checklist = vehicle.checklists.active.first
      status = {title: ""}

      if @active_checklist.present?
        items = @active_checklist.checklist_items  
        notification = vehicle.compliance_notifications.active.order(updated_at: :desc).first
        if notification.present?
          status = {title: notification.get_message, notification: "#{notification.checklist? ? 'checklist' : 'provisioning'}"}
        elsif !items.map(&:value).uniq.compact.blank?
          @date = items.order(updated_at: :desc).first.updated_at
          status = {title: "In Progress (#{formatted_date(@date)})"}
        elsif items.map(&:value).uniq.compact.blank?
          items.map(&:value).uniq.compact.blank?
          status = {title: "Verify"}
        end
      elsif vehicle.checklists.completed.present?
        @date = vehicle.checklists.completed.order(updated_at: :desc).first.updated_at
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

      vehicle.update!(active_checklist_id: active_checklist_id, 
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
