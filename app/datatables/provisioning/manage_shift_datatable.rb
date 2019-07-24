class Provisioning::ManageShiftDatatable
  include ActionView::Helpers::TextHelper

  def initialize(shift)
    @shift = shift
  end

  def as_json(options = {})
    {
      :data => data
    }
  end

  def data
    {
      id: @shift.id,
      name: @shift.name,
      start_time: @shift.start_time,
      end_time: @shift.end_time,
      status: @shift.status.capitalize
    }
  end
end
