require 'geohash'

namespace :employee_trip do

  desc 'Set state option'
  task :set_state => [:environment] do
    employee_trips = EmployeeTrip.all
    employee_trips.each do |et|
      et_state = !et.employee_schedule_id.blank? ? 1 : 0
      et.update(state: et_state)
    end
  end

  desc "Update schedule date"
  task :update_schedule_date => [:environment] do
    employee_trips = EmployeeTrip.includes(:employee_schedule).where("employee_schedule_id is not null")
    employee_trips.each do |et|
      es = et.employee_schedule
      next if es.nil? or es.check_in.nil? or es.check_out.nil?
      schedule_date = es.send(:calculate_schedule_dates, et.created_at.in_time_zone('Chennai'))

      et.update(schedule_date: schedule_date.in_time_zone('Chennai'))
    end
  end

  desc "Update Geohash"
  task :update_geohash => [:environment] do
    @employees = Employee.all
    @employees.each do |employee|
      puts employee.home_address_latitude.to_f
      puts employee.home_address_longitude.to_f
      puts GeoHash.encode(employee.home_address_latitude.to_f, employee.home_address_longitude.to_f, 12)
      employee.update(geohash: GeoHash.encode(employee.home_address_latitude.to_f, employee.home_address_longitude.to_f, 12))
    end
  end

  desc "Create Schedule"
  task :create_schedule => [:environment] do
    # Fetch all employee trips for the current day where schedule id is not null
    date = Time.now.in_time_zone('Chennai')
    date = date - 1.day
    puts date

    @employee_trips = EmployeeTrip.where('schedule_date > ?', (date).beginning_of_day).where('schedule_date < ?', (date).end_of_day).where.not(schedule_date: nil)
    @employee_trips.each do |et|
        @next_week_trip = EmployeeTrip.where('schedule_date > ?', (date + 7.days).beginning_of_day).where('schedule_date < ?', (date + 7.days).end_of_day).where.not(schedule_date: nil).where(employee_id: et.employee_id).where(trip_type: et.trip_type).first
        if !@next_week_trip.present?
                # Create a new employee trip
                new_trip =
                        {
                              employee_id: et.employee_id,
                              date: et.date + 7.days, #sec to min
                              trip_type: et.trip_type,
                              site_id: et.site_id,
                              state: et.state,
                              schedule_date: et.schedule_date + 7.days
                         }
                EmployeeTrip.create!(new_trip)
        end
    end
  end


  desc "Update schedule time to shift time"
  task :migrate_to_shift_time => [:environment] do
    zone = ActiveSupport::TimeZone.new("Chennai")
    Employee.includes(:employee_trips).each do |emp|
      trips = emp.employee_trips.where("schedule_date > ?", Time.now - 1.week).group_by { |et| et.schedule_date.strftime("%U") }
      trips.values.flatten.each_slice(2) do |sch|
        next if sch.length < 2
        schedule_time1 = "#{sch.first.date.in_time_zone(zone).strftime('%H:%M')}"
        schedule_time2 = "#{sch.last.date.in_time_zone(zone).strftime('%H:%M')}"
        check_in_obj, check_out_obj, check_in, check_out = if sch.first.check_in?
          [sch.first, sch.last, schedule_time1, schedule_time2]
        else
          [sch.last, sch.first, schedule_time2, schedule_time1]
        end
        updated_check_in, updated_check_out = time_range_select(check_in, check_in_obj), time_range_select(check_out, check_out_obj)
        shift = find_or_create_shift(updated_check_in, updated_check_out, emp)
        shift_ids = emp.shifts.map(&:id)
        shift_ids << shift.id
        emp.user.shifts = Shift.find(shift_ids.uniq)
        check_in_date, check_out_date = EmployeeTrip.fetch_checkin_and_checkout({check_in: shift.start_time, schedule_date: check_in_obj.schedule_date.to_date}, {check_out: shift.end_time, schedule_date: check_out_obj.schedule_date.to_date}, zone)
        [check_in_obj, check_out_obj].each_with_index do |et, i|
          date = i == 0 ? check_in_date : check_out_date
          et.update(shift_id: shift.id, date: date)
        end
      end
    end
  end

  def time_range_select(input, et)
    output_time = ""
    check_in_range = {"05:45": [0, 5], "06:45": [6, 9], "12:15": [10, 12], "13:45": [13], "14:45": [14], "15:45": [15, 18], "19:45": [19, 20], "21:45": [21, 23]}
    check_out_range = {"00:30": [0], "01:30": [1], "02:00": [2, 5], "06:00": [6, 11], "14:45": [12, 14], "15:30": [15], "16:30": [16, 20], "22:00": [21, 23]}
    input_range = et.check_in? ? check_in_range : check_out_range
    input_range.each do |k, val|
      next unless input.split(":").first.to_i.between?(val.first, val.last)
      output_time = k.to_s
      break
    end
    output_time
  end

  def find_or_create_shift(check_in, check_out, emp)
    shift = Shift.where(start_time: check_in, end_time: check_out).first
    return shift if shift.present?
    shift = Shift.create!(start_time: check_in, end_time: check_out, name: "#{check_in}-#{check_out}", status: "active")
    shift
  end

  desc "Create auto sequence entry in the configurator"
  task :create_auto_sequence_flag_in_configurator => [:environment] do
    Configurator.create!(request_type: 'auto_sequence', value: true)
  end
end
