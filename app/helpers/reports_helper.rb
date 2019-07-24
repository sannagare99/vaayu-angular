module ReportsHelper
  def zero_if_raise
    begin
      result = yield
      result.to_f.nan? ? 0 : result
    rescue
      0
    end
  end

  def get_date_time(date, time, field_name="date")
    zone = ActiveSupport::TimeZone.new("Chennai")
    dat = DateTime.strptime("#{date} #{time}", "%Y-%m-%d %H:%M").in_time_zone(zone)
    field_name == "date" ? dat.strftime("%d-%m-%Y") : dat.strftime("%H:%M")
  end
end
