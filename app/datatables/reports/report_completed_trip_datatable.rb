class Reports::ReportCompletedTripDatatable
  def initialize(trip = nil)
    @trip = trip
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    {
       "DT_RowId" => "#{Trip::DATATABLE_PREFIX}-#{@trip.id}",
       :id => @trip.id,
       :trip_roster => "#{@trip&.start_date&.strftime("%m/%d/%Y")} - #{@trip.id}",
       :driver => @trip.driver.full_name,
       :check_in_time => @trip.employee_trips.minimum(:date)&.strftime("%I:%M%p"),
       :actual_check_in_time => @trip.completed_date&.strftime("%I:%M%p"),
       :average_rating => @trip.average_rating,
       :duration => duration,
       :distance => "#{@trip.scheduled_approximate_distance / 1000}km"
    }
  end

  private
  def duration
    @trip.real_duration.blank? ? '' : "#{@trip.real_duration}min"
  end

end
