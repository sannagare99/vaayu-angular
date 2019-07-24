require File.expand_path(File.join(File.dirname(__FILE__), "../..", "support", "paths"))

# Given(/^Create operator for operator billing$/) do
# 	@operator = FactoryGirl.create(:operator, logistics_company: @logistics_company)
# end

Then(/^I should see all the invoices with their statuses$/) do
	page.find('#customer-invoices-table tr:nth-child(1) td:nth-child(1)').text.should eq("#{@invoice_2.date.localtime.strftime('%m-%d-%Y')} - #{@invoice_2.id}")
	page.find('#customer-invoices-table tr:nth-child(2) td:nth-child(1)').text.should eq("#{@invoice_1.date.localtime.strftime('%m-%d-%Y')} - #{@invoice_1.id}")
	page.find('#customer-invoices-table tr:nth-child(1) td:nth-child(10)').text.should eq('New')
	page.find('#customer-invoices-table tr:nth-child(2) td:nth-child(10)').text.should eq('Paid')
end

Given(/^I create "([^"]*)" invoice data for operator billing$/) do |status|
	case status
	when 'Paid'
		@invoice = Invoice.create(company_type:'EmployeeCompany', company_id: @employee_company.id, date: Time.now - 2.days, start_date: Time.now - 4.days, end_date: Time.now - 2.days, trips_count: 5, amount: 500, status: :paid)
	when 'New'
		@invoice = Invoice.create(company_type:'EmployeeCompany', company_id: @employee_company.id, date: Time.now, start_date: Time.now - 2.days, end_date: Time.now, trips_count: 10, amount: 1000, status: :created)
	when 'Multiple'
		@invoice_1 = Invoice.create(company_type:'EmployeeCompany', company_id: @employee_company.id, date: Time.now - 2.days, start_date: Time.now - 4.days, end_date: Time.now - 2.days, trips_count: 5, amount: 500, status: :paid)
	@invoice_2 = Invoice.create(company_type:'EmployeeCompany', company_id: @employee_company.id, date: Time.now, start_date: Time.now - 2.days, end_date: Time.now, trips_count: 10, amount: 1000, status: :created)
	else
		@invoice = Invoice.create(company_type:'EmployeeCompany', company_id: @employee_company.id, date: Time.now, start_date: Time.now - 2.days, end_date: Time.now, trips_count: 10, amount: 1000, status: :created)
	end
end

Then(/^I should see the "([^"]*)" customer invoices with their statuses$/) do |status|
	page.find('#customer-invoices-table tr:nth-child(1) td:nth-child(1)').text.should eq("#{@invoice.date.localtime.strftime('%m-%d-%Y')} - #{@invoice.id}")
	page.find('#customer-invoices-table tr:nth-child(1) td:nth-child(10)').text.should eq(status)
end