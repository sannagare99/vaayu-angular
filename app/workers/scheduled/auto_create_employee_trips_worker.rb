class AutoCreateEmployeeTripsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options :retry => 0, :dead => false

  # Every day at 23:30
  recurrence { daily.hour_of_day(16).minute_of_hour(00) }

  def perform
    create_employee_trips
  end

  def create_employee_trips
    # Fetch all employee trips for the current day where schedule id is not null
    date = Time.now.in_time_zone('Chennai')
    employee_trips_copied = {}
    employee_trips = EmployeeTrip
      .where('schedule_date > ?', date.beginning_of_day)
      .where('schedule_date < ?', date.end_of_day)
      .where.not(schedule_date: nil)
    employee_trips.each do |et|
      next if employee_trips_copied[et.id]
      next_week_trip = EmployeeTrip
        .where('schedule_date > ?', (date + 7.days).beginning_of_day)
        .where('schedule_date < ?', (date + 7.days).end_of_day)
        .where.not(schedule_date: nil)
        .where(employee_id: et.employee_id)
        .where(trip_type: et.trip_type)
        .first
      if !next_week_trip.present?
        if et.employee_cluster
          # If part of a cluster, create a new cluster and create new employee
          # trips for all employee trips within that cluster.
          #
          # Rely on memoization with help of employee_trips_copied hash to
          # ensure same employee trip is not processed multiple times
          ec = EmployeeCluster.create(date: et.employee_cluster.date)
          et.employee_cluster.employee_trips.each do |ett|
            copy_employee_trip(ett, employee_cluster: ec)
            employee_trips_copied[ett.id] = true
          end
        else
          # Create a new employee trip
          copy_employee_trip(et)
          employee_trips_copied[et.id] = true
        end
      end
    end
  end

  def copy_employee_trip(employee_trip, options={})
    EmployeeTrip.create!({
      zone:           employee_trip.zone,
      state:          employee_trip.state,
      site_id:        employee_trip.site_id,
      trip_type:      employee_trip.trip_type,
      employee_id:    employee_trip.employee_id,
      date:           employee_trip.date + 7.days, #sec to min
      schedule_date:  employee_trip.schedule_date + 7.days,
      bus_rider:      employee_trip.employee.bus_travel,
      route_order:    employee_trip.route_order
    })
  end
end
