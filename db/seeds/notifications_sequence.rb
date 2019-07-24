# set sequence field to existing notifications
# Notification.all.each do |notification|
#   notification.set_sequence
#   notification.save!
# end

# set sequence to notifications of required trips
notifications = Notification.includes(:trip).where('trips.scheduled_date' => Time.now.beginning_of_day.advance(days: -1)..Time.now.end_of_day.advance(days: +1))

notifications.each do |notification|
  notification.set_sequence
  notification.save!
end