class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for "notification_channel_for_#{params['user_id']}"
  end

  def unsubscribed
  end
end