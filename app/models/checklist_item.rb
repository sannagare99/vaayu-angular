class ChecklistItem < ApplicationRecord
  enum compliance_type: [:quality, :behaviour, :document, :safety]

  after_update :create_or_update_notification
  after_save :complete_checklist

  belongs_to :checklist

  after_save :update_compliance_message

  scope :checked, -> { where(value: true) }

  def to_id
    key.downcase.gsub(" ", "-")
  end

  private

  def create_or_update_notification
    obj = checklist.driver.present? ? checklist.driver : checklist.vehicle
    message = key + " Not Proper"
    if checklist.driver.present?
      ComplianceNotification.create({message: message, compliance_type: 0, driver_id: obj.id}) if value_changed? && value == false
    else
      ComplianceNotification.create({message: message, compliance_type: 0, vehicle_id: obj.id}) if value_changed? && value == false
    end
    notification = obj.compliance_notifications.select { |x| x.message == message }.first if value_changed? && value == true
    notification.update(status: 1) if notification.present? && value_changed? && value == true
  end

  def complete_checklist
    items = checklist.checklist_items.map(&:value)
    checklist.update(status: 1) if items.uniq.size == 1 and items.uniq.first == true
  end

  def update_compliance_message
    return if checklist.driver.blank? and checklist.vehicle.blank?
    obj = checklist.driver.present? ? checklist.driver : checklist.vehicle

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
