class Configurators::ManageComplianceDatatable
  include ActionView::Helpers::TextHelper

  def initialize(compliance)
    @compliance = compliance
  end

  def as_json(options = {})
    { data: data }
  end

  def data
    {
      "DT_RowId" => @compliance.id,
      id: @compliance.id,
      key: @compliance.key,
      modal_type: @compliance.modal_type,
      compliance_type: @compliance.compliance_type
    }
  end
end
