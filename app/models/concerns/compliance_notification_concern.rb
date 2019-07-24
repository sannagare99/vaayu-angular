module ComplianceNotificationConcern
  extend ActiveSupport::Concern

  included do
    after_update :create_or_update_notification
  end

  def create_or_update_notification
    self.class::NOTIFICATION_FIELDS.each do |k, v|
      next unless self.send(k.to_s + "_changed?")
      notification = self.compliance_notifications.active.select { |x| x.message == v }.first
      next if notification.nil?
      notification.update(status: 1)
    end
  end
end