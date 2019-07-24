class CompliancesController < ApplicationController
  before_action :set_compliance, only: [:edit, :update, :destroy]
  before_action :update_params, only: [:create, :update]

  def index
    render json: Configurators::ManageCompliancesDatatable.new(view_context)
  end

  def new
    @compliance = Compliance.new
  end

  def create
    compliance = Compliance.new(compliance_params)
    compliance.save
    @errors = compliance.errors.full_messages.to_sentence
    @datatable_name = 'compliances'

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to configurators_path(anchor: @datatable_name) }
    end
  end

  def edit
    @compliance = Compliance.find(params[:id])
  end

  def update
    @compliance.update(compliance_params)
    @errors = @compliance.errors.full_messages.to_sentence
    @datatable_name = 'compliances'

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to configurators_path(anchor: @datatable_name) }
    end
  end

  def destroy
    @compliance.destroy
    respond_to do |format|
      format.html { redirect_to configurators_path(anchor: anchor) }
      format.json { head :no_content }
    end
  end

  private

  def compliance_params
    params.require(:compliance).permit!
  end

  def set_compliance
    @compliance = Compliance.find(params[:id])
  end

  def update_params
    compliance_params[:modal_type] = compliance_params[:modal_type].to_i
    compliance_params[:compliance_type] = compliance_params[:compliance_type].to_i
  end
end
