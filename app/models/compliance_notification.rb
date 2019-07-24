class ComplianceNotification < ApplicationRecord
  enum compliance_type: [:checklist, :provisioning]
  enum status: [:active, :completed]

  belongs_to :driver
  belongs_to :vehicle

  after_update :update_sort_status
  after_update :update_compliance_message

  after_create :update_sort_status
  after_create :update_compliance_message  

  def self.create_provisioning_notification(configuration, obj)
    notifications = obj.compliance_notifications.provisioning.active
    obj.class::NOTIFICATION_FIELDS.each do |k, v|
      notification = notifications.select { |x| x.message == v }.first
      configurator = Configurator.where(request_type: configuration[k][:field]).first
      configurator_flag = Configurator.where(request_type: configuration[k][:flag]).first

      if notification.present?
        #Check if we need to resolve this notification
        if configurator.nil? || configurator_flag.nil? || configurator_flag.value == "0"
          notification.update(status: 1)
        end

        if !configurator_flag.nil? && configurator_flag.value == "1"
          if Date.today < obj.send(k) - configurator.value.to_i.days
            notification.update(status: 1)
          end
        end

        #Do not create a notification in this case
        next
      end
      next if obj.send(k).nil?    
      next if configurator.nil?
      next if configurator_flag.nil? || configurator_flag.value == "0"
      next unless Date.today >= obj.send(k) - configurator.value.to_i.days
      # if configurator.value == '0'
      #   v = "#{v} Expired"
      # elsif configurator.value == '1'
      #   v = "#{v} Expires in 1 day"
      # else
      #   v = "#{v} Expires in #{configurator.value} days"
      # end
      cn = ComplianceNotification.new({message: v, compliance_type: 1})
      cn.driver_id = obj.id if obj.class.name.downcase == "driver"
      cn.vehicle_id = obj.id if obj.class.name.downcase == "vehicle"
      cn.save
    end
  end

  # Get the message for compliance and provisioning notification
  def get_message
    if self.checklist?
      self.message
    else
      case self.message
        when 'Badge'
          date = self.driver.badge_expire_date
        when 'Licence'
          date = self.driver.licence_validity
        when 'Insurance'
          date = self.vehicle.insurance_date
        when 'PUC'
          date = self.vehicle.puc_validity_date
        when 'Permit'
          date = self.vehicle.permit_validity_date
        when 'FC'
          date = self.vehicle.fc_validity_date
      end

      if Date.today == date
        "#{self.message} Expired today"
      elsif Date.today == date - 1
        "#{self.message} Expires in 1 day"
      elsif Date.today < date - 1
        date = (date - Date.today).to_i
        "#{self.message} Expires in #{date} days"
      else
        "#{self.message} Expired"
      end
    end
  end

  def update_sort_status
    return if driver.blank? and vehicle.blank?
    obj = driver.present? ? driver : vehicle

    if vehicle.present?
      status = -1

      notification = vehicle.compliance_notifications.active.order(updated_at: :desc).first
      # This notification to be shown below any car broke down or leave notification
      case vehicle.status
      when 'vehicle_broke_down'
        status = 0
      end

      if notification.present?
        notification.checklist? ? status = 1 : status = 2
      end

      case vehicle.status
      when 'vehicle_ok_pending'
        status = 3
      when 'vehicle_broke_down'
        status = 0
      when 'vehicle_broke_down_pending'
        status = 4
      end
    else
      status = -1
      if obj.status == 'on_leave'
        status = 0  
      end

      notification = obj.compliance_notifications.active.order(updated_at: :desc).first
      # This notification to be shown below any car broke down or leave notification
      if notification.present?
        notification.checklist? ? status = 1 : status = 2
      end

      driver_request = DriverRequest.where(:driver => obj).where('start_date > ?', Time.now).where(:request_state => [:cancel, :pending]).first
      if driver_request.present?
        status = 3
      end      
    end

    obj.update_column('sort_status', status)     
  end

  def update_compliance_message
    return if driver.blank? and vehicle.blank?
    obj = driver.present? ? driver : vehicle

    @active_checklist = obj.checklists.active.first
    status = {title: ""}

    if @active_checklist.present?
      items = @active_checklist.checklist_items  
      notification = obj.compliance_notifications.active.order(updated_at: :desc).first
      if notification.present?
        status = {title: notification.get_message, notification: "#{notification.checklist? ? 'checklist' : 'provisioning'}"}
      elsif !items.map(&:value).uniq.compact.blank?
        @date = items.order(updated_at: :desc).first.updated_at
        status = {title: "In Progress (#{formatted_date(@date)})"}
      elsif items.map(&:value).uniq.compact.blank?
        items.map(&:value).uniq.compact.blank?
        status = {title: "Verify"}
      end
    elsif obj.checklists.completed.present?
      @date = obj.checklists.completed.order(updated_at: :desc).first.updated_at
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

    obj.update!(active_checklist_id: active_checklist_id, 
      compliance_notification_message: notification_status,
      compliance_notification_type: notification_type)

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
