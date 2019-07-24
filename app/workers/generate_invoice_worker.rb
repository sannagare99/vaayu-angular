class GenerateInvoiceWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3, :dead => false

  def perform(id, type)
    invoice =
        case type
          when 'business_associate'
            Invoices::BusinessAssociate.new(id)
          when 'employee_company'
            Invoices::EmployeeCompany.new(id)
        end
    invoice.generate
  end
end