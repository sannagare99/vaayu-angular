require 'roo'

class IngestEmployeeShiftWorker < IngestWorker
  def parse_ingest_xlsx
    ingest_error = false
    sheet = Roo::Spreadsheet.open(file_url, extension: 'xlsx')

    rows = sheet.to_a
    date_header = rows[0]
    headers = rows[1].map {|h| h.gsub!(' ', ''); h.underscore}
    rows[2..-1].each.with_index(1) do |row, row_index|
      row_hash = row_hash(row, headers)
      logger.info "Processing row number: #{row_index}"
      begin
        ActiveRecord::Base.transaction do
          employee = process_employee_details(row_hash)
          process_employee_schedule(employee, row, headers, date_header)
        end
      rescue => e
        ingest_error = true
        ingest_job.failed_row_count += 1
        logger.error "Error processing row number: #{row_index}: #{e.message}"
        CSV.open(error_csv_file, 'a+') do |csv|
          csv << [ingest_job.id, get_employee_id(row_hash), row_index, e.message]
        end
      end
      ingest_job.processed_row_count += 1
    end
    raise IngestError if ingest_error
  end

  def row_hash(row, headers)
    headers.zip(row).to_h
  end

  def get_trip_date(date)
    d = date.is_a?(String) ? DateTime.strptime(date, '%d-%m-%y') : date
    d.strftime('%d-%m-%Y')
  end

  def process_employee_details(row)
    f_name, l_name = row['employee_name']&.split
    employee = provision_employee(
      email: row['email'],
      phone: row['phone_number'] && row['phone_number'].is_a?(Float) ? row['phone_number'].to_i : row['phone_number'],
      f_name: f_name,
      l_name: l_name,
      employee_id: get_employee_id(row),
      address: row['address'],
      gender: row['gender'],
      area: row['area'],
      process_code: row['process_code'],
      site: Site.last,
      zone: Zone.last,
      employee_company: EmployeeCompany.first,
      allow_update: true
    )
    employee
  end

  def provision_shift(employee, row, index)
    check_in, check_out = row[index], row[index+1]
    shift_provisioned = false
    shift = employee.shifts.find_by(start_time: check_in, end_time: check_out)
    if shift.nil?
      shift = Shift.find_by(start_time: check_in, end_time: check_out)
      if shift.nil?
        shift = Shift.create!(name: "#{check_in} - #{check_out}",
                              start_time: check_in,
                              end_time: check_out)
        shift.activate!
        shift_provisioned = true
      end
      employee.user.shift_users.create!(shift: shift)
      if shift_provisioned
        ingest_job.schedule_provisioned_count += 1
      else
        ingest_job.schedule_assigned_count += 1
      end
    end
    shift
  end

  def get_check_in_shift(employee, row,index)
    check_in = row[index]
    Shift.find_by(start_time: check_in)
  end

  def get_check_out_shift(employee, row,index)
    check_out = row[index+1]
    Shift.find_by(end_time: check_out)
  end  

  def provision_employee_trips(employee, shift, row, index, date)
    check_in_date, check_out_date = Time.zone.parse("#{date} #{row[index]}"), Time.zone.parse("#{date} #{row[index+1]}")
    check_out_date = check_out_date + 1.day if check_out_date <= check_in_date
    schedule_date = Time.zone.parse("#{date} 10:00:00")
    employee.employee_trips.where(
      schedule_date: schedule_date,
      date: check_in_date,
      trip_type: 'check_in',
      site: Site.last
    ).first_or_create!
    employee.employee_trips.where(
      schedule_date: schedule_date,
      date: check_out_date,
      trip_type: 'check_out',
      site: Site.last
    ).first_or_create!
  end

  def provision_check_in_trip(employee, shift, row, index, date)
    check_in_date = Time.zone.parse("#{date} #{row[index]}")
    schedule_date = Time.zone.parse("#{date} 10:00:00")
    employee.employee_trips.where(
      schedule_date: schedule_date,
      date: check_in_date,
      trip_type: 'check_in',
      site: Site.first
    ).first_or_create!
  end

  def provision_check_out_trip(employee, shift, row, index, date)
    check_out_date = Time.zone.parse("#{date} #{row[index+1]}")
    shift_start_time = Time.zone.parse("#{date} #{shift.start_time}")
    shift_end_time = Time.zone.parse("#{date} #{shift.end_time}")

    check_out_date = check_out_date + 1.day if shift_end_time <= shift_start_time

    schedule_date = Time.zone.parse("#{date} 10:00:00")

    employee.employee_trips.where(
      schedule_date: schedule_date,
      date: check_out_date,
      trip_type: 'check_out',
      site: Site.first
    ).first_or_create!
  end

  def process_employee_schedule(employee, row, headers, date_header)
    # column index where check_in/check_out times start
    start_index = headers.index('login')
    start_index.step(row.size-1, 2).each do |index|
      date = get_trip_date(date_header[index])

      schedule_date = Time.zone.parse("#{date} 10:00:00")
      # Clear trips for this employee for thie schedule date
      EmployeeTrip.upcoming.where(schedule_date: schedule_date).where(employee: employee).no_trip_created.destroy_all

      next if row[index].blank? && row[index+1].blank?
      #Provision new shift if possible
      if row[index].present? && row[index+1].present?
        shift = provision_shift(employee, row, index)        
      end

      if row[index].present?
        if shift.present?
          check_in_shift = shift
        else
          check_in_shift = get_check_in_shift(employee, row, index)
        end

        if check_in_shift.present? && EmployeeTrip.upcoming.where(schedule_date: date).where(employee: employee).where(trip_type: :check_in).where.not(trip: nil).first.blank?   
          provision_check_in_trip(employee, check_in_shift, row, index, date)
        end
      end

      if row[index+1].present?
        if shift.present?
          check_out_shift = shift
        else
          check_out_shift = get_check_out_shift(employee, row, index)
        end

        if check_out_shift.present? && EmployeeTrip.upcoming.where(schedule_date: date).where(employee: employee).where(trip_type: :check_out).where.not(trip: nil).first.blank?
          provision_check_out_trip(employee, check_out_shift, row, index, date)
        end
      end
    end if start_index
  end
end
