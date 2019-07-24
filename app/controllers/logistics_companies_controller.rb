class LogisticsCompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    @logistic_companies = LogisticsCompany.all.order('id DESC')
    @logistic_company = LogisticsCompany.new

    @operator = User.new
    @operator.entity = Operator.new
    respond_to do |format|
      format.html
      format.json { render json: LogisticsCompaniesDatatable.new(view_context) }
    end
  end

  def edit
  end

  def show
  end

  def get_all
    @logistics_companies = LogisticsCompany.all
    logistics_company_id = nil
    if current_user.operator?
      logistics_company_id = current_user.entity[:logistics_company_id]
    end
    render :json => {
      logistics_companies: @logistics_companies,
      logistics_company_id: logistics_company_id
    }
  end

  def create
    if current_user.admin? || current_user.operator?
      @logistic_company = LogisticsCompany.new(company_params.values.first)
      respond_to do |format|
        if @logistic_company.save
          format.json { render json: LogisticCompanyDatatable.new(@logistic_company), status: :created, location: @logistic_companies }
        else
          format.json { render json: @logistic_company.errors, status: '404' }
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @logistic_company.update(company_params[params[:id]])
        format.json { render json: LogisticCompanyDatatable.new(@logistic_company), status: :ok, location: @logistic_company }
      else
        format.json { render json: @logistic_company.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if current_user.admin?
      @logistic_company.destroy
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @logistic_company = LogisticsCompany.find_by_prefix(params[:id])
  end

  def company_params
    params.require(:data).permit!
  end

  def operator_params
    params.require(:user).permit(
        :id, :f_name, :m_name, :l_name, :email, :role, :phone,
        :entity_attributes => [
            :logistics_company_id, :legal_name, :pan, :tan, :business_type, :service_tax_no, :hq_address
        ]
    )
  end
end
