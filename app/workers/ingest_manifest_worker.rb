require 'roo'
require 'services/trip_validation_service'

class IngestManifestWorker < IngestWorker
  def parse_ingest_xlsx
    sheet = Roo::Spreadsheet.open(file_url, extension: 'xlsx')

    rows = sheet.to_a
    headers = rows.find {|r| is_row_header?(r)}.map {|h| h.gsub!(' ', ''); h.underscore}
    clusters = get_clusters(rows)

    begin
      pre_process_clusters(clusters)
      process_clusters(clusters, headers)
      post_process_clusters(clusters)
    rescue => e
      logger.error "Error processing clusters: #{e.message}"
      raise
    end
  end

  def pre_process_clusters(clusters)
    clusters.each do |cluster|
      cluster_metadata = get_cluster_metadata(cluster)
      # Remove all existing clusters for the queue that haven't been manifested
      EmployeeCluster
        .joins(employee_trips: :employee)
        .where(date: cluster_metadata[:date])
        .includes(:trip)
        .where('trips.id': nil)
        .where('employee_trips.trip_type': cluster_metadata[:trip_type])
        .destroy_all
      EmployeeTrip
        .where(date: cluster_metadata[:date])
        .where(status: [:upcoming, :assigned, :reassigned])
        .where(trip_id: nil)
        .where(trip_type: cluster_metadata[:trip_type])
        .destroy_all
    end
  end

  def post_process_clusters(clusters)
  end

  def is_manifest_header?(row)
    row[0] =~ /Date/i
  end

  def is_row_header?(row)
    row[0] =~ /Sequence/i
  end

  def get_clusters(rows)
    clusters = []
    rows.each.with_index(1) do |row, row_index|
      if is_manifest_header?(row)
        clusters << []
        clusters[-1] << {row: row, row_index: row_index}
      elsif is_row_header?(row)
        next
      else
        clusters[-1] << {row: row, row_index: row_index}
      end
    end
    clusters
  end

  def process_clusters(clusters, headers)
    ingest_error = false
    clusters.each do |cluster|
      logger.info "Processing cluster on row number: #{cluster[0][:row_index]}"
      begin
        process_cluster(cluster, headers)
      rescue => e
        ingest_error = true
        logger.error "Error processing cluster #{cluster[0][:row_index]}: #{e.message}"
      end
    end
    raise IngestError if ingest_error
  end

  def process_cluster(cluster, headers)
    ingest_error = false
    cluster_rows = cluster[1..-1]
    employee_ids = cluster_rows.map {|c| row_hash = headers.zip(c[:row]).to_h; get_employee_id(row_hash)}
    cluster_metadata = get_cluster_metadata(cluster)

    trips = Trip
      .joins(employee_trips: :employee)
      .where(status: [
        'created',
        'assign_request_declined',
        'accepted',
        'assigned',
        'assign_request_expired',
        'assign_requested',
        'active',
        'completed',
        'canceled',
      ])
      .where(trip_type: cluster_metadata[:trip_type])
      .where('employees.employee_id' => employee_ids)
      .where('employee_trips.date' => cluster_metadata[:date].beginning_of_day..cluster_metadata[:date].end_of_day)

    if trips.count == employee_ids.count
      # Manifest Already exists
      cluster_rows.each do |c|
        ingest_error = true
        row = c[:row]
        row_hash = headers.zip(row).to_h
        ingest_job.failed_row_count += 1
        ingest_job.processed_row_count += 1
        CSV.open(error_csv_file, 'a+') do |csv|
          csv << [ingest_job.id, get_employee_id(row_hash), c[:row_index], 'Trip Already Exists']
        end      
      end      
    else
      cluster = EmployeeCluster.new({
        date: cluster_metadata[:date],
        driver: cluster_metadata[:driver]
      })
      cluster_rows.each do |c|
        row = c[:row]
        row_hash = headers.zip(row).to_h
        begin
          employee = process_employee(row_hash, cluster_metadata)
          provision_employee_trip(employee, cluster, cluster_metadata, row_hash, c[:row_index])
        rescue => e
          ingest_error = true
          ingest_job.failed_row_count += 1
          logger.error "Error processing row number: #{c[:row_index]}, employee_id: #{get_employee_id(row_hash)}, error: #{e.message}"
          CSV.open(error_csv_file, 'a+') do |csv|
            csv << [ingest_job.id, get_employee_id(row_hash), c[:row_index], e.message]
          end
          if cluster.error.blank?
            cluster.error = 'Errors: ' + get_employee_id(row_hash)
          else
            cluster.error = cluster.error + ", #{get_employee_id(row_hash)}"
          end
        end
        ingest_job.processed_row_count += 1
      end
      if TripValidationService.is_female_exception(cluster.employee_trips.pluck(:id), cluster_metadata[:trip_type])
        cluster.error = [cluster.error, 'female_exception'].compact.join(', ')
      end
      cluster.save!
    end
    raise IngestError if ingest_error
  end

  def process_employee(row_hash, cluster_metadata)
    f_name, l_name = row_hash['employee_name']&.split
    employee = provision_employee(
      email: row_hash['email'],
      phone: row_hash['mobile_number'] && row_hash['mobile_number'].is_a?(Float) ? row_hash['mobile_number'].to_i : row_hash['mobile_number'],
      f_name: f_name,
      l_name: l_name,
      employee_id: get_employee_id(row_hash),
      address: row_hash['pick_up_address'],
      gender: row_hash['gender'] =~ /^m/i ? 'male' : 'female',
      site: Site.first,
      zone: Zone.last,
      employee_company: EmployeeCompany.first
    )
    process_schedule(employee, cluster_metadata)
    employee
  end

  def process_schedule(employee, cluster_metadata)
    time = cluster_metadata[:date].strftime('%H:%M')
    shift = employee.shifts.find_by('start_time = ? or end_time = ?', time, time)
    if shift.nil?
      shift = Shift.find_by('start_time = ? or end_time = ?', time, time)
      raise 'Unknown Shift' if shift.nil?
      employee.user.shift_users.create!(shift: shift)
      ingest_job.schedule_assigned_count += 1
    end
  end

  def get_sequence(row, row_index)
    row['sequence'].blank? ? row_index : row['sequence'].to_i
  end

  def provision_employee_trip(employee, cluster, cluster_metadata, row, row_index)
    schedule_date = Time.zone.parse("#{cluster_metadata[:date].to_date} 10:00:00")
    if cluster_metadata[:trip_type] == :check_out
      time = cluster_metadata[:date].strftime('%H:%M')
      shift = employee.shifts.find_by('end_time = ?', time)
      check_in_time, check_out_time =
        Time.zone.parse("#{cluster_metadata[:date].to_date} #{shift.start_time}"),
        Time.zone.parse("#{cluster_metadata[:date].to_date} #{shift.end_time}")
      schedule_date = schedule_date - 1.day if check_in_time >= check_out_time
    end

    #Delete employee trip for this schedule date
    if cluster_metadata[:trip_type] == :check_in
      EmployeeTrip.upcoming.where(schedule_date: schedule_date).where(employee: employee).where(trip_type: :check_in).no_trip_created.destroy_all
    elsif cluster_metadata[:trip_type] == :check_out
      EmployeeTrip.upcoming.where(schedule_date: schedule_date).where(employee: employee).where(trip_type: :check_out).no_trip_created.destroy_all
    end

    employee_trip = employee.employee_trips
      .where(schedule_date: schedule_date)
      .where(trip_type: cluster_metadata[:trip_type])
      .where.not(trip: nil)
      .first

    if employee_trip.present?
      ingest_error = true
      ingest_job.failed_row_count += 1
      CSV.open(error_csv_file, 'a+') do |csv|
        csv << [ingest_job.id, get_employee_id(row_hash), row_index, 'Trip Already Exists']
      end  
    end
    employee_trip ||= EmployeeTrip.create!({
      date: cluster_metadata[:date],
      trip_type: cluster_metadata[:trip_type],
      site: employee.site,
      employee: employee,
      schedule_date: schedule_date,
      bus_rider: employee.bus_travel,      
      route_order: get_sequence(row, row_index),
      date: cluster_metadata[:date],
      is_clustered: true,
      cluster_error: nil,
      employee_cluster: cluster      
    })

    employee_trip
  end

  def get_trip_type(direction)
    direction =~ /to.office|check.in/i ? :check_in : :check_out
  end

  def get_trip_date(date)
    d = date.is_a?(String) ? DateTime.strptime(date, '%d/%m/%y %H:%M %p') : date
    d = (d + 1.minute).beginning_of_hour if d.min == 59
    d = (d + 1.second).beginning_of_minute if d.second == 59
    d
  end

  def get_cluster_metadata(cluster)
    header = cluster[0][:row]
    date = get_trip_date(header[1]).change(offset: Time.zone.now.strftime('%z'))
    {
      date: date,
      trip_type: get_trip_type(header[3]),
      driver: Driver.joins(:user).find_by('users.phone = ?', header[7].to_i)
    }
  end
end
