class Reports::ReportOtdSummaryDatatable
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
       :date => @date.first&.strftime("%d-%m-%Y"),
       :shift_time => @date.last,
       :total_logouts => @trips_data[:total_logouts],
       :logouts_catered_to => @trips_data[:logouts_catered_to],
       :logouts_canceled => @trips_data[:logouts_canceled],
       :logouts_delayed => @trips_data[:logouts_delayed],
       :avg_delay_to_logout => @trips_data[:avg_delay_to_logout]
    }
  end

  private

  # get params from all used cars
  def trips_data
    trips = @trip_group
    logouts_catered_to = logouts_canceled = logouts_delayed = avg_delay_to_logout = 0
    trips.each do |trip|
      #Fetch all the trip routes
      logouts_catered_to += 1 if trip.completed? || trip.cancel_status.present?
      logouts_canceled += 1 if trip.canceled? && trip.cancel_status.nil?
      # avg_delay_to_logout = 0
      # if trip.completed? && trip.completed_date >= trip.approximate_trip_end_date
      #   logouts_delayed += 1
      #   avg_delay_to_logout += trip.completed_date - trip.approximate_trip_end_date
      # end

      if trip.completed? && !trip.completed_date.nil?
        delay = (trip.completed_date - trip.employee_trip_date) / 60
        if delay.to_i > 10
          logouts_delayed += 1
          avg_delay_to_logout += delay.to_i
        end
      end
    end

    # begin
      @trips_data = {
          :total_logouts => trips.count,
          :logouts_catered_to => logouts_catered_to,
          :logouts_canceled => logouts_canceled,
          :logouts_delayed => logouts_delayed,
          :avg_delay_to_logout => formatted_duration(zero_if_raise {(avg_delay_to_logout.to_f / logouts_delayed.to_f).round(2)})
      }
    # rescue
      # binding.pry
    # end
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


