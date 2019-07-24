class EmployeeSchedule < ApplicationRecord

  belongs_to :employee
  has_many :employee_trips

  enum day: [:sun, :mon, :tue, :wed, :thu, :fri, :sat]
  # validates :day, uniqueness: { scope: :employee_id }
  validate :check_in_and_check_out_present

  # Update related employee trips if schedule changed
  after_update :update_employee_trips, if: Proc.new { |s| s.check_in_changed? || s.check_out_changed? }

  # Check in and check out time were set
  scope :complete, -> { where.not(check_in: nil, check_out: nil)}

  # Returns an integer value for day
  def day_number
    day_before_type_cast
  end

  # Is both check_in and check_out were set
  def complete?
    ! (check_in.blank? || check_out.blank?)
  end

  # Checks if there are any upcoming employee trips
  def upcoming_employee_trips_exist?
    employee_trips.upcoming.any?
  end

  # create next trip from provided time
  def create_upcoming_employee_trips(time_from = Time.zone.now)
    # @TODO split into universal methods for check in and check out
    return unless complete?

    check_in_date, check_out_date = calculate_employee_trip_dates(time_from)

    employee_trips.create! [
                               { date: check_in_date, employee: employee, trip_type: :check_in },
                               { date: check_out_date, employee: employee, trip_type: :check_out }
                           ]
    # if day.to_sym == :mon
    #   auto_cluster
    # end
  end

  # Recalculate employee trip dates
  def update_upcoming_employee_trips
    check_in_date, check_out_date = calculate_employee_trip_dates

    employee_trips.upcoming.check_in.update_all(date: check_in_date)
    employee_trips.upcoming.check_out.update_all(date: check_out_date)
    # if day.to_sym == :mon
    #   auto_cluster
    # end
  end

  # Destroy all upcoming employee trips
  # for this schedule
  def remove_upcoming_employee_trips
    employee_trips.upcoming.no_trip_created.destroy_all
    # if day.to_sym == :mon
    #   auto_cluster
    # end
  end

  # Parse check in time with timezone
  def check_in=(time)
    begin
      write_attribute(:check_in, Time.zone.parse(time.to_s))
    rescue
      write_attribute(:check_in, time)
    end
  end

  # Parse check out time with timezone
  def check_out=(time)
    begin
      write_attribute(:check_out, Time.zone.parse(time.to_s))
    rescue
      write_attribute(:check_out, time)
    end
  end

  # HH:MM check in output for forms
  def check_in_formatted
    self.check_in.in_time_zone(Time.zone).strftime('%H:%M') if self.check_in
  end

  # HH:MM check out output for forms
  def check_out_formatted
    self.check_out.in_time_zone(Time.zone).strftime('%H:%M') if self.check_out
  end
  private

  # Update upcoming employee trips
  # if schedule times have been changed
  def update_employee_trips

    # check in and check out set
    if complete?
      if upcoming_employee_trips_exist?
        # update employee trips if they already exists
        update_upcoming_employee_trips
      else
        # create new trips
        create_upcoming_employee_trips
      end
    else
      # if schedule cleared -> remove upcoming trips
      remove_upcoming_employee_trips
    end
    data = {employee_id: employee.user_id, data: {employee_id: employee.user_id, push_type: :update_schedule}}
    PushNotificationWorker.perform_async(employee.user_id, :update_schedule, data)
  end

  # Validate if both: check in and check out were set
  def check_in_and_check_out_present
    errors.add(:base, 'Please specify both: check in and check out time') if check_in.blank? ^ check_out.blank?
  end

  # Find out date and time for employees next check in / check out trips
  def calculate_employee_trip_dates(time_from = Time.zone.now)
    # if today is scheduled weekday -- check that trip hasn't passed yet
    if time_from.wday == day_number && (compare_times(check_in, time_from) || compare_times(check_out, time_from))
      next_trip_date = time_from
    else
      # or look for the next scheduled weekday
      next_trip_date = calculate_next_weekday_date( time_from, day_number )
    end

    # generate check in next trip
    check_in_date = change_time( next_trip_date, check_in )

    # generate check out next trip
    # add one day if shift's check_out time scheduled for tomorrow
    check_out_date = change_time( next_trip_date, check_out )

    check_out_date += 1.day if check_out_date <= check_in_date

    return check_in_date, check_out_date
  end

  def calculate_schedule_dates(time_from)
    if time_from.wday == day_number && (compare_times(check_in, time_from) || compare_times(check_out, time_from))
      next_trip_date = time_from
    else
      # or look for the next scheduled weekday
      next_trip_date = calculate_next_weekday_date( time_from, day_number )
    end

    next_trip_date
  end

  # Find next weekday from provided time
  # i.e. find next Monday or find next Thursday
  def calculate_next_weekday_date(time_from = Time.zone.now, week_day)
    days_to_next_date = ( week_day - time_from.wday) > 0 ?
        week_day - time_from.wday  : 7 + week_day - time_from.wday

    time_from + days_to_next_date.days
  end

  # Compare two Time objects independent of their dates
  def compare_times(time1, time2)
    time1.strftime( '%H%M' ) > time2.strftime( '%H%M' )
  end

  # Apply hours and time from new_time to changed_time
  # I.e. changed_time = 2012-02-19 17:19:00 +0300
  # new_time = 2016-10-25 19:00:36 +0300
  # the result will be 2012-02-19 19:00:00 +0300
  def change_time(changed_time, new_time)
    new_time.change day: changed_time.day, month: changed_time.month, year: changed_time.year
  end

  def auto_cluster
    for i in 0..2
      runs = 25
      if i == 0
        # puts "Running morning K Means"
        employee_schedule = EmployeeSchedule.where(day: 1, check_in: '00:30:00')
      elsif i == 1
        # puts "Running afternoon K Means"
        employee_schedule = EmployeeSchedule.where(day: 1, check_in: '03:30:00')
      elsif i == 2
        # puts "Running evening K Means"
        employee_schedule = EmployeeSchedule.where(day: 1, check_in: '09:30:00')
      end

      employees = []

      zones = []

      employee_schedule.each do |schedule|
        employees << { id: schedule.employee.id, lat: schedule.employee.home_address_latitude.to_f, lng: schedule.employee.home_address_longitude.to_f, distance: schedule.employee.distance_to_site.to_f } 
      end

      data = employees.map {|employee| [employee[:lat], employee[:lng]] }

      cluster_length = (employee_schedule.length / 4).to_i

      t = Time.now

      kmeans = KMeansClusterer.run(cluster_length, data, labels: employees, runs: runs, scale_data: true)

      elapsed = Time.now - t
      new_employee_zones = []

      kmeans.sorted_clusters.each do |cluster|
        clustered_employee_data = []
        cluster.points.each do |point|
          clustered_employee_data << point.label
        end
        clustered_employee_data = clustered_employee_data.sort_by { |k| k[:distance] }

        if clustered_employee_data.length > 4
          clustered_employee_data.each_slice(4).to_a.each do |slice|
            new_employee_zones << slice
          end
        else
          new_employee_zones << clustered_employee_data
        end
      end

      # puts "\nBest of #{runs} runs (total time #{elapsed.round(2)}s):"
      # puts "Total number of previous zones #{cluster_length + 3}"
      # puts "#{new_employee_zones.length} clusters in #{kmeans.iterations} iterations, #{kmeans.runtime.round(2)}s, SSE #{kmeans.error.round(2)}"
      # puts "Silhouette score: #{kmeans.silhouette.round(2)}"

      new_employee_zones.each_with_index do |zone_cluster, i|
        # puts "\n#-----#\n\n"
        zone_cluster.each do |employee|
          @zone = Zone.where(:id => i + 1).first
          if@zone.blank?
            @zone = Zone.create!(name: i + 1)
          end
          @employee = Employee.where(:id => employee[:id])
          @employee.update(zone: @zone)
        end
        # puts zone_cluster
      end

    end
  end

end
