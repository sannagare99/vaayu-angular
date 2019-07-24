class ProvisioningController < ApplicationController
  before_action :get_objects, only: [:index]

  def index
    @employer = User.new
    @employer.entity = Employer.new

    @operator = User.new
    @operator.entity = Operator.new

    @vehicle = Vehicle.new
    @site = Site.new

    @line_manager = User.new
    @line_manager.entity = LineManager.new

    @transport_desk_manager = User.new
    @transport_desk_manager.entity = TransportDeskManager.new

    @ingest_job = IngestJob.new
  end

  private
    def get_objects
      if (logistics_company = current_user.entity.try(:logistics_company))
        @employee_companies = EmployeeCompany.where(:logistics_company => logistics_company)
      elsif current_user.admin?
        @employee_companies = EmployeeCompany.all.order('name ASC')
      end

    end
end
