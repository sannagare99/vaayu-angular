class Invoices::EmployeeCompany < Invoices::Base
  def initialize(id)
    #TODO Need to check if obj exist
    @company = ::EmployeeCompany.find(id)
    super
  end

  private
  def get_trips(period)
    @trips = Trip.joins(:driver => {:logistics_company => :employee_companies})
        .by_period(period)
        .where('employee_companies.id' => @company.id, 'status' => 'completed')
    @trips.group_by{|el| el.send(@pay_period)}
  end
end