class Reports::ReportOtaSummaryDatatable
  include ReportsHelper
  def initialize(date, trip_group = nil)
    @trip_group = trip_group
    @date = date
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    @trips_data = trips_data
    {
       date: @date.first.to_datetime&.strftime("%d-%m-%Y"),
       shift_time: @date.last,
       total_logins: @trips_data[:total_logins],
       logins_catered_to: @trips_data[:logins_catered_to],
       logins_canceled: @trips_data[:logins_canceled],
       logins_delayed: @trips_data[:logins_delayed],
       avg_delay_to_login: @trips_data[:avg_delay_to_login]
    }
  end

  private

  # get params from all used cars
  def trips_data
    trips = @trip_group
    logins_catered_to = logins_canceled = logins_delayed = avg_delay_to_login = 0
    trips.each do |trip|
      #Fetch all the trip routes
      logins_catered_to += 1 if trip.completed? || trip.cancel_status.present?
      logins_canceled += 1 if trip.canceled? && trip.cancel_status.nil?
      # avg_delay_to_login = 0
      # if trip.completed? && trip.completed_date >= trip.approximate_trip_end_date
      #   logins_delayed += 1
      #   avg_delay_to_login += trip.completed_date - trip.approximate_trip_end_date
      # end
      if trip.completed? && !trip.completed_date.nil?
        delay = (trip.completed_date - trip.employee_trip_date) / 60
        if delay.to_i > 10
          logins_delayed += 1
          avg_delay_to_login += delay.to_i
        end
      end

    end

    begin
      @trips_data = {
          :total_logins => trips.count,
          :logins_catered_to => logins_catered_to,
          :logins_canceled => logins_canceled,
          :logins_delayed => logins_delayed,
          :avg_delay_to_login => formatted_duration(zero_if_raise {(avg_delay_to_login.to_f / logins_delayed.to_f).round(2)})
      }
    rescue
      # binding.pry
    end
  end

  def formatted_duration(total_minutes)
    hours = zero_if_raise{(total_minutes / 60).to_i}
    minutes = zero_if_raise{(total_minutes % 60).to_i}

    if hours == 0
      "#{ minutes } m"
    else
      "#{ hours } h #{ minutes } m"
    end
  end
end



