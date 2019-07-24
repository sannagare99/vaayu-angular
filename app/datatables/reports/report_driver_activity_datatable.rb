class Reports::ReportDriverActivityDatatable
  include ReportsHelper

  def initialize(driver)
    @driver = driver
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      first_name: @driver.user.f_name,
      last_name: @driver.user.l_name,
      phone: @driver.user.phone,
      licence_number: @driver.licence_number,
      last_used_vehicle: @driver.vehicle&.plate_number,
      site: @driver.site.name,
      vendor_id: @driver.logistics_company_id,
      sign_in_count: @driver.user.sign_in_count,
      current_sign_at: @driver.user.current_sign_in_at.present? ? @driver.user.current_sign_in_at&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M")&.to_s : "-",
      last_sign_in_at: @driver.user.last_sign_in_at.present? ? @driver.user.last_sign_in_at&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M")&.to_s : "-",
      last_active_time: @driver.user.last_active_time == Time.new(2009, 01, 01).to_date ? '-' : @driver.user.last_active_time&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M")&.to_s,
      last_active: @driver.user.last_active_time.present? ? "<= #{(Date.today - @driver.user.last_active_time.to_date).to_i} Days" : ""
    }
  end
end


