class Reports::ReportEmployeeSatisfactionDatatable
  include ReportsHelper
  def initialize(et)
    @et = et
  end

  def as_json(options = {})
    {
        data: data
    }
  end

  def data
    {
      date: @et.date&.strftime("%d-%m-%Y"),
      trip_id: @et.trip_id,
      status: @et.trip_status.titleize,
      shift_type: @et.trip_type.titleize,
      shift_time: get_date_time(@et.date.to_date, @et.shift_time, "time"),
      vehicle_no: @et.vehicle_no,
      employee_id: @et.employee_id,
      employee_name: @et.employee_name,
      rating: @et.rating,
      rating_feedback: @et.rating_feedback
    }
  end
end



