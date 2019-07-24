class Invoices::BusinessAssociate < Invoices::Base
  def initialize(id)
    #TODO Need to check if obj exist
    @company = ::BusinessAssociate.find(id)
    super
  end

  private

  def get_trips(period)
    @trips = Trip.joins(:driver)
        .by_period(period)
        .where('drivers.logistics_company_id' => @company.id, 'status' => 'completed')

    @trips.group_by{|el| el.send(@pay_period)}
  end
end