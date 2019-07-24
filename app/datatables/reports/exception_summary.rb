class Reports::ExceptionSummary
  include ReportsHelper
  def initialize(trip_group = nil)
    @trip_group = trip_group
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    @trips_data = trips_data
    {
       :date => @trip_group.first,
       :total_rosters_submitted => @trips_data[:total_rosters_submitted],
       :total_rosters_fulfilled => @trips_data[:total_rosters_fulfilled],
       :late_check_ins => @trips_data[:late_check_ins].to_s + '%',
       :late_departures => @trips_data[:late_departures].to_s + '%',
       :employees_as_no_show => @trips_data[:employees_as_no_show].to_s + '%',
       :pick_up_no_show => @trips_data[:pick_up_no_show].to_s + '%',
       :drop_off_no_show => @trips_data[:drop_off_no_show].to_s + '%'
    }
  end

  private

  # get params from all used cars
  def trips_data
    trips = @trip_group.last.uniq
    total_rosters_fulfilled = late_check_ins = late_departures = employees_as_no_show = total_employee = pick_up_no_show = drop_off_no_show = 0
    trips.each do |trip|
      #Fetch all the trip routes
      trip_routes = TripRoute.where(:trip => trip)
      trip_routes.each do |trip_route|
        if trip_route.driver_arrived_date.blank? || trip_route.on_board_date.blank?
          next
        end     
        if trip_route.approximate_driver_arrive_date < trip_route.driver_arrived_date
          if trip.check_in?
            late_check_ins += 1
          else
            late_departures += 1
          end
        end
      end

      total_rosters_fulfilled += 1 if trip.completed?
      # if trip.real_duration.to_i > trip.scheduled_approximate_duration.to_i
      #   late_check_ins += 1
      # end
      # late_departures += 1 if !trip.start_date.blank? && trip.start_date > trip.scheduled_date
      total_employee += trip.employee_trips.count
      if (trip_routs = TripRoute.where(:trip => trip).where(:status => 'missed')).count > 0
        employees_as_no_show += trip_routs.count
        if trip.check_in?
          pick_up_no_show += trip_routs.count
        else
          drop_off_no_show += trip_routs.count
        end
      end

    end

    begin
      @trips_data = {
          :total_rosters_submitted => trips.count,
          :total_rosters_fulfilled => total_rosters_fulfilled,
          :late_check_ins => zero_if_raise {(late_check_ins.to_f / total_employee.to_f * 100).round(2)},
          :late_departures => zero_if_raise {(late_departures.to_f / total_employee.to_f * 100).round(2)},
          :employees_as_no_show => zero_if_raise {(employees_as_no_show.to_f / total_employee.to_f * 100).round(2)},
          :pick_up_no_show => zero_if_raise {(pick_up_no_show.to_f / total_employee.to_f * 100).round(2)},
          :drop_off_no_show => zero_if_raise {(drop_off_no_show.to_f / total_employee.to_f * 100).round(2)}
      }
    rescue
      # binding.pry
    end
  end


end



