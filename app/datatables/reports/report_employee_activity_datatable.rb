class Reports::ReportEmployeeActivityDatatable
  include ReportsHelper

  def initialize(employee)
    @employee = employee
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      first_name: @employee&.user&.f_name,
      last_name: @employee&.user&.l_name,
      employee_id: @employee&.employee_id,
      phone: @employee&.user&.phone,
      email: @employee&.user&.email,
      site: @employee&.site&.name,
      sign_in_count: @employee&.user&.sign_in_count,
      current_sign_at: @employee&.user&.current_sign_in_at&.present? ? @employee&.user&.current_sign_in_at&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M")&.to_s : "-",
      last_sign_in_at: @employee&.user&.last_sign_in_at&.present? ? @employee&.user&.last_sign_in_at&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M")&.to_s : "-",
      last_active_time: @employee&.user&.last_active_time == Time.new(2009, 01, 01).to_date ? '-' : @employee&.user&.last_active_time&.in_time_zone("Kolkata")&.strftime("%d-%m-%Y %H:%M")&.to_s,
      last_active: @employee&.user&.last_active_time.present? ? "<= #{(Date.today - @employee&.user&.last_active_time&.to_date).to_i} Days" : "",
      status: @employee&.user&.status&.humanize
    }
  end
end


