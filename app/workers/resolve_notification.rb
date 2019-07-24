class ResolveNotification
  include Sidekiq::Worker
  sidekiq_options :retry => 3, :dead => false

  # check if driver is assigned,
  # if not -- reject manifest, set proper status
  # and send proper notifications
  def perform(notification_id)
    notification = Notification.find(notification_id)
    if notification.present?
    	#update notification
    	notification.update!(resolved_status: true)
    end
  end
end