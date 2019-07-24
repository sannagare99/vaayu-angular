require 'services/google_service'

class IngestError < StandardError; end

class IngestWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3, dead: false, queue: :ingest_job

  attr_reader :ingest_job, :error_csv_file

  def perform(ingest_job_id)
    set_time_zone
    @ingest_job = IngestJob.find(ingest_job_id)
    if ingest_job.may_process?
      ingest_job.process!
      logger.info "Started processing of Ingest Job ID: #{ingest_job_id}, IngestType: #{ingest_job.ingest_type}"

      set_error_csv_file
      begin
        process
      rescue => e
        logger.error "Error processing ingest: #{e.message}"
        error_file = File.open(error_csv_file)
        ingest_job.error_file = error_file
        error_file.close
        ingest_job.fail if ingest_job.may_fail?
      end

      ingest_job.complete if ingest_job.may_complete?
      ingest_job.save
      IngestMailer.notify(ingest_job).deliver_now!
    end
  end

  def process(&block)
    extn = File.extname(ingest_job.file.original_filename)
    send("parse_ingest_#{extn[1..-1]}", &block)
  end

  def get_address(address)
    return {} if address.blank?
    if address =~ /\d+\.\d+,\d+\.\d+/
      lat, lng = address.split(',').map(&:to_f)
      result = GoogleService.new.reverse_geocode({lat: lat, lng: lng}).first
      unless result.nil? || !result.key?(:formatted_address)
        address = result[:formatted_address]
      end
    elsif !address.blank?
      result = GoogleService.new.geocode(address).first
      unless result.nil? || !result.key?(:geometry)
        coordinates = result[:geometry][:location]
        lat, lng = coordinates[:lat], coordinates[:lng]
      end
    end
    raise 'Invalid Address' if address.blank? || lat.blank? || lng.blank?
    {
      home_address: address,
      home_address_latitude: lat,
      home_address_longitude: lng
    }
  end

  def provision_employee(emp_hash)
    allow_update = emp_hash.delete(:allow_update)
    employee = Employee.joins(:user).find_by('users.email = ? or employee_id = ?', emp_hash[:email], emp_hash[:employee_id])
    if employee.nil?
      user = User.new(
        email: emp_hash[:email],
        phone: emp_hash[:phone],
        f_name: emp_hash[:f_name],
        l_name: emp_hash[:l_name],
        password: 'password',
        entity_type: 'Employee',
        process_code: emp_hash[:process_code],
        entity_attributes: {
          employee_id: emp_hash[:employee_id],
          gender: emp_hash[:gender],
          site: emp_hash[:site],
          zone: emp_hash[:zone],
          landmark: emp_hash[:area],
          employee_company: emp_hash[:employee_company]
        }.compact.merge(get_address(emp_hash[:address]))
      )
      user.save_with_notify!
      employee = user.entity
      ingest_job.employee_provisioned_count += 1
    else
      if allow_update
        employee.user.update!({
          f_name: emp_hash[:f_name],
          l_name: emp_hash[:l_name],
          phone: emp_hash[:phone],
          email: emp_hash[:email],
          process_code: emp_hash[:process_code],
          entity_attributes: {
            entity_id: employee.id,
            employee_id: emp_hash[:employee_id],
            gender: emp_hash[:gender],
            landmark: emp_hash[:area],
          }.compact.merge(get_address(emp_hash[:address]))
        }.compact)
      end
    end
    employee
  end

  private

  def set_time_zone
    Time.zone = 'Asia/Kolkata'
  end

  def set_error_csv_file
    if @error_csv_file.nil?
      @error_csv_file = Rails.root.join('tmp', "#{ingest_job.id}_errors.csv")
      CSV.open(error_csv_file, 'wb') do |csv|
        csv << ['ingest_job_id', 'employee_id', 'row_index', 'error']
      end
    end
  end

  def file_url
    ingest_job.file.url
  end

  def get_employee_id(row)
    return row['employee_id'] && row['employee_id'].to_s.sub(/\..*$/,'')
  end
end
