class DashboardController < ApplicationController
  def index
    trips = Trip.where(status: 'completed')
    @stats = {
      total_trips: get_count_with_trend(trips, :start_date),
      distance_per_trip: get_avg_with_trend(trips, :start_date, :planned_approximate_distance),
      duration_per_trip: get_avg_with_trend(trips, :start_date, :real_duration),
      employee_check_in: get_perc_with_trend(trips.select('distinct trips.id').joins(:employee_trips).where(trip_type: :check_in).where('trips.completed_date <= employee_trips.date'), trips, :start_date),
      manifest_fulfillment: get_perc_with_trend_multi(trips, :start_date, Trip, :scheduled_date),
      on_time_arrivals: {
        on_time_check_in: get_perc_with_trend(trips.select('distinct trips.id').joins(:employee_trips).where(trip_type: :check_in).where('trips.completed_date <= employee_trips.date'), trips.where(trip_type: :check_in), :start_date),
        on_time_check_out: get_perc_with_trend(trips.select('distinct trips.id').joins(:employee_trips).where(trip_type: :check_out).where('trips.start_date <= employee_trips.date'), trips.where(trip_type: :check_out), :start_date),
        average_delay: get_avg_with_trend(trips.joins(:employee_trips), :start_date, 'timediff(trips.completed_date, employee_trips.date)'),
        total_delayed_trips: get_count_with_trend(trips.joins(:employee_trips).where("(trips.trip_type = 'check_in' and trips.completed_date > employee_trips.date) or (trips.trip_type = 'check_out' and trips.start_date > employee_trips.date)"), :start_date),
        total_affected_logins: get_count_with_trend(trips.joins(:employee_trips).select('distinct employee_trips.employee_id').where(trip_type: :check_in).where('trips.completed_date > employee_trips.date'), :start_date)
      },
      employee_rating: get_avg_with_trend(EmployeeTrip.where(status: 'completed'), :date, :rating),
      fleet_utilization: {
        overall: get_fleet_utilization,
        by_capacity: get_fleet_utilization_by_capacity
      },
      cost_per_trip: get_cost_per_trip,
      cost_per_employee: get_cost_per_employee,
      driver_stats: {
        active_driver: get_count_with_trend(Driver.select('distinct drivers.id').joins(:trips), 'trips.start_date'),
        distance: get_sum_with_trend(trips, :start_date, :planned_approximate_distance),
        duration: get_sum_with_trend(trips, :start_date, :planned_approximate_duration),
      }
    }
  end

  def completed_trips
    trips = Trip.where(status: :completed)
    @data = {
      trend: {
        total: get_by_period(trips, :start_date)
          .where(start_date: get_micro_range)
          .count,
        to_work: get_by_period(trips, :start_date)
          .where(start_date: get_micro_range)
          .where(trip_type: :check_in)
          .count,
        to_home: get_by_period(trips, :start_date)
          .where(start_date: get_micro_range)
          .where(trip_type: :check_out)
          .count
      },
      exceptions_breakup: {
        total: {
          total: Trip
            .where(start_date: get_micro_range)
            .count,
          all_good: trips
            .where(start_date: get_micro_range)
            .count,
          with_exceptions: Trip
            .where(start_date: get_micro_range)
            .includes(:trip_routes)
            .where('trip_routes.cancel_exception': true)
            .count,
          ola_uber: Trip
            .where(start_date: get_micro_range)
            .where(book_ola: true)
            .count
        },
        to_work: {
          total: Trip
            .where(start_date: get_micro_range)
            .where(trip_type: :check_in)
            .count,
          all_good: trips
            .where(start_date: get_micro_range)
            .where(trip_type: :check_in)
            .count,
          with_exceptions: Trip
            .where(start_date: get_micro_range)
            .where(trip_type: :check_in)
            .includes(:trip_routes)
            .where('trip_routes.cancel_exception': true)
            .count,
          ola_uber: Trip
            .where(start_date: get_micro_range)
            .where(trip_type: :check_in)
            .where(book_ola: true)
            .count
        },
        to_home: {
          total: Trip
            .where(start_date: get_micro_range)
            .where(trip_type: :check_out)
            .count,
          all_good: trips
            .where(start_date: get_micro_range)
            .where(trip_type: :check_out)
            .count,
          with_exceptions: Trip
            .where(start_date: get_micro_range)
            .where(trip_type: :check_out)
            .includes(:trip_routes)
            .where('trip_routes.cancel_exception': true)
            .count,
          ola_uber: Trip
            .where(start_date: get_micro_range)
            .where(trip_type: :check_out)
            .where(book_ola: true)
            .count
        }
      },
      exceptions_summary: {
        total: Trip
          .where(start_date: get_micro_range)
          .joins(:trip_route_exceptions)
          .group('trip_route_exceptions.exception_type')
          .count
          .transform_keys {|k| TripRouteException.exception_types.key(k)},
        to_work: Trip
          .where(start_date: get_micro_range)
          .where(trip_type: :check_in)
          .joins(:trip_route_exceptions)
          .group('trip_route_exceptions.exception_type')
          .count
          .transform_keys {|k| TripRouteException.exception_types.key(k)},
        to_home: Trip
          .where(start_date: get_micro_range)
          .where(trip_type: :check_out)
          .joins(:trip_route_exceptions)
          .group('trip_route_exceptions.exception_type')
          .count
          .transform_keys {|k| TripRouteException.exception_types.key(k)}
      },
      fulfillment: {
        total: {
          scheduled: EmployeeTrip
            .where(date: get_micro_range)
            .count + TripChangeRequest
            .where(new_date: get_micro_range)
            .count,
          transported: EmployeeTrip
            .where(date: get_micro_range)
            .where(status: :completed)
            .count,
          cancelled: EmployeeTrip
            .where(date: get_micro_range)
            .where(status: :canceled)
            .count,
          no_shows: EmployeeTrip
            .where(date: get_micro_range)
            .where(status: :missed)
            .count
        }
      },
      overall_mileage: {
        total: {
          without_employees: trips
            .where(start_date: get_micro_range)
            .joins(:trip_routes)
            .where('trips.trip_type = 0 AND trip_routes.planned_route_order = 0')
            .sum(:planned_distance) / 1000, # in kms
          with_employees:  trips
            .where(start_date: get_micro_range)
            .joins(:trip_routes)
            .where('(trips.trip_type = 0 AND trip_routes.planned_route_order > 0) OR trips.trip_type = 1')
            .sum(:planned_distance) / 1000, # in kms
        },
        to_work: {
          without_employees: trips
            .where(start_date: get_micro_range)
            .joins(:trip_routes)
            .where(trip_type: :check_in)
            .where('trip_routes.planned_route_order = 0')
            .sum(:planned_distance) / 1000, # in kms
          with_employees:  trips
            .where(start_date: get_micro_range)
            .joins(:trip_routes)
            .where(trip_type: :check_in)
            .where('trip_routes.planned_route_order > 0')
            .sum(:planned_distance) / 1000, # in kms
        },
        to_home: {
          without_employees: trips
            .where(start_date: get_micro_range)
            .joins(:trip_routes)
            .where(trip_type: :check_out)
            .where('trip_routes.planned_route_order = (select MAX(trip_routes.planned_route_order) from trip_routes where trip_routes.trip_id = trips.id)')
            .sum(:planned_distance) / 1000, # in kms
          with_employees:  trips
            .where(start_date: get_micro_range)
            .joins(:trip_routes)
            .where(trip_type: :check_out)
            .where('trip_routes.planned_route_order < (select MAX(trip_routes.planned_route_order) from trip_routes where trip_routes.trip_id = trips.id)')
            .sum(:planned_distance) / 1000, # in kms
        }
      },
      average_mileage: {
        to_work: trips
          .where(start_date: get_micro_range)
          .where(trip_type: :check_in)
          .average(:planned_approximate_distance).to_i / 1000, # in kms
        to_home: trips
          .where(start_date: get_micro_range)
          .where(trip_type: :check_out)
          .average(:planned_approximate_distance).to_i / 1000, # in kms
      },
      average_duration: {
        to_work: trips
          .where(start_date: get_micro_range)
          .where(trip_type: :check_in)
          .average(:real_duration).to_i,
        to_home: trips
          .where(start_date: get_micro_range)
          .where(trip_type: :check_out)
          .average(:real_duration).to_i,
      },
      distance_per_employee: {
        to_work: EmployeeTrip
          .where(date: get_micro_range)
          .where(trip_type: :check_in)
          .where(status: :completed)
          .joins(:trip_route)
          .average('trip_routes.planned_distance').to_i / 1000,
        to_home: EmployeeTrip
          .where(date: get_micro_range)
          .where(trip_type: :check_out)
          .where(status: :completed)
          .joins(:trip_route)
          .average('trip_routes.planned_distance').to_i / 1000,
      },
      duration_per_employee: {
        to_work: EmployeeTrip
          .where(date: get_micro_range)
          .where(trip_type: :check_in)
          .where(status: :completed)
          .joins(:trip_route)
          .average('trip_routes.planned_duration').to_i,
        to_home: EmployeeTrip
          .where(date: get_micro_range)
          .where(trip_type: :check_out)
          .where(status: :completed)
          .joins(:trip_route)
          .average('trip_routes.planned_duration').to_i
      },
      by_shift: EmployeeTrip
        .where(date: get_micro_range)
        .where(status: :completed)
        .where("DATE_FORMAT(date, '%h:%i') in (select distinct start_time from shifts)")
        .group("DATE_FORMAT(date, '%h:%i')")
        .count,
      by_vehicle: EmployeeTrip
        .where(date: get_micro_range)
        .where(status: :completed)
        .joins(trip: :vehicle)
        .group('vehicles.seats')
        .count,
      by_site: EmployeeTrip
        .where(date: get_micro_range)
        .where(status: :completed)
        .joins(trip: :site)
        .group('sites.name')
        .count
    }
  end

  def fleet_utilization
    @data = {
      by_operator: Trip
        .select('distinct vehicles.id')
        .where(start_date: get_micro_range)
        .where("DATE_FORMAT(start_date, '%h:%i') in (select distinct start_time from shifts)")
        .joins(vehicle: {driver: {logistics_company: {operators: :user}}})
        .group('CONCAT(users.f_name, users.l_name)')
        .group("DATE_FORMAT(start_date, '%h:%i')")
        .count,
      load_factor: get_micro_fleet_utilization
    }
  end

  def ota
    @data = {
      on_time_arrivals: {
        total: get_by_period(Trip, :start_date)
          .where(status: :completed)
          .where(trip_type: :check_in)
          .where(start_date: get_micro_range)
          .count,
        ota: get_by_period(Trip, :start_date)
          .select('distinct trips.id')
          .where(status: :completed)
          .where(trip_type: :check_in)
          .where(start_date: get_micro_range)
          .joins(:employee_trips)
          .where('trips.completed_date <= employee_trips.date')
          .count
      },
      on_time_departures: {
        total: get_by_period(Trip, :start_date)
          .where(status: :completed)
          .where(trip_type: :check_out)
          .where(start_date: get_micro_range)
          .count,
        ota: get_by_period(Trip, :start_date)
          .select('distinct trips.id')
          .where(status: :completed)
          .where(trip_type: :check_out)
          .where(start_date: get_micro_range)
          .joins(:employee_trips)
          .where('trips.start_date <= employee_trips.date')
          .count
      }
    }
  end

  def costs

  end

  def exceptions
    @data = {
      trend: {
        total: get_by_period(Trip, :start_date)
          .where(start_date: get_micro_range)
          .includes(:trip_routes)
          .where('trip_routes.cancel_exception': true)
          .count,
        to_work: get_by_period(Trip, :start_date)
          .where(start_date: get_micro_range)
          .where(trip_type: :check_in)
          .includes(:trip_routes)
          .where('trip_routes.cancel_exception': true)
          .count,
        to_home: get_by_period(Trip, :start_date)
          .where(start_date: get_micro_range)
          .where(trip_type: :check_out)
          .includes(:trip_routes)
          .where('trip_routes.cancel_exception': true)
          .count
      },
      breakup: Trip
        .where(start_date: get_micro_range)
        .joins(:trip_route_exceptions)
        .group('trip_route_exceptions.exception_type')
        .count
        .transform_keys {|k| TripRouteException.exception_types.key(k)},
      by_shift: Trip
        .where(start_date: get_micro_range)
        .where("DATE_FORMAT(start_date, '%h:%i') in (select distinct start_time from shifts)")
        .joins(:trip_route_exceptions)
        .group('trip_route_exceptions.exception_type')
        .group("DATE_FORMAT(start_date, '%h:%i')")
        .count
        .transform_keys {|k| [TripRouteException.exception_types.key(k[0]), k[1]]}
    }
  end

  private

  def get_micro_fleet_utilization
    utilization = lambda do |range|
      Trip.find_by_sql("select DATE_FORMAT(start_date, '%h:%i') shift,
                               CONCAT(users.f_name, users.l_name) as user_name,
                               avg(utilization) * 100 as util_perc
                        from (
                          select trips.id trips_id, count(employee_trips.id) / vehicles.seats as utilization
                          from trips
                          inner join employee_trips on employee_trips.trip_id = trips.id
                          inner join vehicles on vehicles.id = trips.vehicle_id
                          group by trips.id
                        ) as utilization
                        inner join trips on trips.id = utilization.trips_id
                        inner join vehicles on vehicles.id = trips.vehicle_id
                        inner join drivers on drivers.id = vehicles.driver_id
                        inner join logistics_companies on logistics_companies.id = drivers.logistics_company_id
                        inner join operators on operators.logistics_company_id = logistics_companies.id
                        inner join users on users.entity_id = operators.id AND users.entity_type = 'Operator'
                        where trips.status = 'completed'
                              and DATE_FORMAT(start_date, '%h:%i') in (select distinct start_time from shifts)
                              and start_date between '#{range[0].first.strftime('%Y-%m-%d %H:%M:%S')}'
                                  and '#{range[0].last.strftime('%Y-%m-%d %H:%M:%S')}'
                        group by DATE_FORMAT(start_date, '%h:%i'), CONCAT(users.f_name, users.l_name)")
    end
    utilization.call(get_micro_range)
  end

  def get_fleet_utilization
    utilization_per_seat_count = lambda do |range|
      EmployeeTrip.find_by_sql("select avg(utilization) * 100 as perc_util
        from (
          select count(employee_trips.id) / vehicles.seats as utilization
          from employee_trips
          inner join trips on trips.id = employee_trips.trip_id
          inner join vehicles on vehicles.id = trips.vehicle_id
          where trips.status = 'completed' and trips.start_date between '#{range[0].first.strftime("%Y-%m-%d %H:%M:%S")}' and '#{range[0].last.strftime("%Y-%m-%d %H:%M:%S")}'
          group by employee_trips.trip_id
        ) as utilization_table")
    end
    value = utilization_per_seat_count.call(get_range).first['perc_util'].to_f
    previous_value = utilization_per_seat_count.call(get_previous_range).first['perc_util'].to_f
    {
      value: value,
      trend: value >= previous_value
    }
  end

  def get_fleet_utilization_by_capacity
    utilization_per_seat_counts = lambda do |range|
      util_by_capacity = EmployeeTrip.find_by_sql("select vehicles_seats capacity, avg(utilization) * 100 perc_util
        from (select count(employee_trips.id) / vehicles.seats as utilization, vehicles.seats as vehicles_seats
          from employee_trips
          inner join trips on trips.id = employee_trips.trip_id
          inner join vehicles on vehicles.id = trips.vehicle_id
          where trips.status = 'completed' and trips.start_date between '#{range[0].first.strftime("%Y-%m-%d %H:%M:%S")}' and '#{range[0].last.strftime("%Y-%m-%d %H:%M:%S")}'
          group by trip_id
        ) as utilization
        group by vehicles_seats")
      util_by_capacity.inject({}) {|h,r| h[r['capacity']] = r['perc_util'].to_f; h}
    end
    values = utilization_per_seat_counts.call(get_range)
    previous_values = utilization_per_seat_counts.call(get_previous_range)
    {
      value: values,
      trend: values.keys.inject({}) {|h,cap| h[cap] = values[cap].to_f >= previous_values[cap].to_f; h }
    }
  end

  def get_cost_per_trip
    cost_per_trip = lambda do |range|
      TripInvoice.find_by_sql("select avg(amount) cost_per_trip
        from (select sum(trip_amount + trip_penalty + trip_toll) amount
        from trip_invoices
        inner join trips on trips.id = trip_invoices.trip_id
        where trips.status = 'completed' and trips.start_date between '#{range[0].first.strftime("%Y-%m-%d %H:%M:%S")}' and '#{range[0].last.strftime("%Y-%m-%d %H:%M:%S")}'
        group by trip_id
        ) as trip_amount_per_trip")
    end
    value = cost_per_trip.call(get_range).first['cost_per_trip'].to_f
    previous_value = cost_per_trip.call(get_previous_range).first['cost_per_trip'].to_f
    {
      value: value,
      trend: value >= previous_value
    }
  end

  def get_cost_per_employee
    cost_per_emp = lambda do |range|
      TripInvoice.find_by_sql("select avg(amount) cost_per_emp
      from (
        select sum(trip_amount + trip_penalty + trip_toll) amount
        from trip_invoices
        inner join trips on trips.id = trip_invoices.trip_id
        inner join employee_trips on employee_trips.trip_id = trips.id
        where trips.status = 'completed' and trips.start_date between '#{range[0].first.strftime("%Y-%m-%d %H:%M:%S")}' and '#{range[0].last.strftime("%Y-%m-%d %H:%M:%S")}'
        group by employee_trips.trip_id, employee_trips.employee_id
      ) as trip_amount_per_trip_employee")
    end
    value = cost_per_emp.call(get_range).first['cost_per_emp'].to_f
    previous_value = cost_per_emp.call(get_previous_range).first['cost_per_emp'].to_f
    {
      value: value,
      trend: value >= previous_value
    }
  end

  def get_count_with_trend(scope, field)
    value = scope.where(field => get_range).count
    previous_value = scope.where(field => get_previous_range).count
    {
      value: value,
      trend: value >= previous_value
    }
  end

  def get_avg_with_trend(scope, field, avg_field)
    value = scope.where(field => get_range).average(avg_field).to_f
    previous_value = scope.where(field => get_previous_range).average(avg_field).to_f
    {
      value: value,
      trend: value >= previous_value
    }
  end

  def get_sum_with_trend(scope, field, sum_field)
    value = scope.where(field => get_range).sum(sum_field).to_f
    previous_value = scope.where(field => get_previous_range).sum(sum_field).to_f
    {
      value: value,
      trend: value >= previous_value
    }
  end

  def get_perc_with_trend(scope, total_scope, field)
    total = total_scope.where(field => get_range).count
    value = total == 0 ? 0.0 : scope.where(field => get_range).count.to_f / total
    previous_value = scope.where(field => get_previous_range).count.to_f / total_scope.where(field => get_previous_range).count
    {
      value: (value.nan? ? 0 : value) * 100,
      trend: value >= previous_value
    }
  end

  def get_perc_with_trend_multi(scope, field, total_scope, total_field)
    total = total_scope.where(total_field => get_range).count
    value = total == 0 ? 0.0 : scope.where(field => get_range).count.to_f / total_scope.where(total_field => get_range).count
    previous_value = scope.where(field => get_previous_range).count.to_f / total_scope.where(total_field => get_previous_range).count
    {
      value: (value.nan? ? 0 : value) * 100,
      trend: value >= previous_value
    }
  end

  def get_range
    today_start_of_day = (Time.now.in_time_zone('Chennai')).beginning_of_day
    case params['period']
    when 'day'
      [today_start_of_day-1.day..Time.now.in_time_zone('Chennai')]
    when 'week'
      [today_start_of_day - 1.week..today_start_of_day]
    when 'month'
      [today_start_of_day - 1.month..today_start_of_day]
    else
      [today_start_of_day-1.day..Time.now.in_time_zone('Chennai')]
    end
  end

  def get_previous_range
    range = get_range.first
    period = 1.send(params['period'] || 'day')
    [(range.first - period)..(range.last - period)]
  end

  def get_micro_range
    today_start_of_day = Time.now.utc.beginning_of_day.in_time_zone('Chennai')
    case params['period']
    when 'day'
      [today_start_of_day - 7.day..Time.now.in_time_zone('Chennai')]
    when 'week'
      [today_start_of_day - 7.week..today_start_of_day]
    when 'month'
      [today_start_of_day - 7.month..today_start_of_day]
    else
      [today_start_of_day - 7.day..Time.now.in_time_zone('Chennai')]
    end
  end

  def get_by_period(scope, field)
    case params['period']
    when 'day'
      scope.group("DATE(#{field})")
    when 'week'
      scope.group("CONCAT(WEEK(#{field}), '/', YEAR(#{field}))")
    when 'month'
      scope.group("CONCAT(MONTH(#{field}), '/', YEAR(#{field}))")
    else
      scope.group("DATE(#{field})")
    end
  end
end
