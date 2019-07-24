module TripScopes
  extend ActiveSupport::Concern

  included do

    # Future employee trips
    scope :upcoming, -> { where('date >= ?', Time.new.in_time_zone('Chennai')) }
    # Employee Trips today or later
    scope :upcoming_trips_today_or_later, -> { where('date >= ?', Time.new.in_time_zone('Chennai').beginning_of_day) }    
    # Past employee trips
    scope :past, -> { where('date < ?', Time.new.in_time_zone('Chennai')) }
    # Started from today
    scope :today_or_later, -> { where('scheduled_date >= ?', Time.new.in_time_zone('Chennai').beginning_of_day) }


    # Fetch trips that will be in 2.hours or 1.days or 5.years
    scope :upcoming_in, -> (duration = 3.hours) { where(scheduled_date: Time.new .. Time.new + duration) }
  end
end
