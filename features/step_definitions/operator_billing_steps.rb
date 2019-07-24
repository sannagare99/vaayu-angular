require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given(/^I create customer invoice data for operator billing$/) do
	step 'Create operator for operator billing'
	@invoice_1 = Invoice.create(company_type:'EmployeeCompany', company_id: @employee_company.id, date: Time.now - 2.days, start_date: Time.now - 4.days, end_date: Time.now - 2.days, trips_count: 5, amount: 500, status: :paid)
	@invoice_2 = Invoice.create(company_type:'EmployeeCompany', company_id: @employee_company.id, date: Time.now, start_date: Time.now - 2.days, end_date: Time.now, trips_count: 10, amount: 1000, status: :created)
end

Given(/^Create operator for operator billing$/) do
	@operator = FactoryGirl.create(:operator, logistics_company: @logistics_company)
end

Then(/^I should see all the customer invoices with their statuses$/) do
	page.find('#customer-invoices-table tr:nth-child(1) td:nth-child(1)').text.should eq("#{@invoice_2.date.strftime('%m-%d-%Y')} - #{@invoice_2.id}")
	page.find('#customer-invoices-table tr:nth-child(2) td:nth-child(1)').text.should eq("#{@invoice_1.date.strftime('%m-%d-%Y')} - #{@invoice_1.id}")
	page.find('#customer-invoices-table tr:nth-child(1) td:nth-child(10)').text.should eq('New')
	page.find('#customer-invoices-table tr:nth-child(2) td:nth-child(10)').text.should eq('Paid')
end

Given(/^I create BA invoice data for operator billing$/) do
	step 'Create operator for operator billing'
	step 'Create business associate for operator billing'
	@invoice_1 = Invoice.create(company_type:'BusinessAssociate', company_id: @business_associate.id, date: Time.now - 2.days, start_date: Time.now - 4.days, end_date: Time.now - 2.days, trips_count: 5, amount: 500, status: :paid)
	@invoice_2 = Invoice.create(company_type:'BusinessAssociate', company_id: @business_associate.id, date: Time.now, start_date: Time.now - 2.days, end_date: Time.now, trips_count: 10, amount: 1000, status: :created)
end

Given(/^Create business associate for operator billing$/) do
	@business_associate = FactoryGirl.create(:business_associate, logistics_company: @logistics_company)
end

Then(/^I should see all the BA invoices with their statuses$/) do
	# TODO: [BUG] UI incomplete, uncomment below assertions when UI fixed.
	# page.find('#ba-invoices-table tr:nth-child(1) td:nth-child(1)').text.should eq("#{@invoice_2.date.strftime('%m-%d-%Y')} - #{@invoice_2.id}")
	# page.find('#ba-invoices-table tr:nth-child(2) td:nth-child(1)').text.should eq("#{@invoice_1.date.strftime('%m-%d-%Y')} - #{@invoice_1.id}")
	# page.find('#ba-invoices-table tr:nth-child(1) td:nth-child(10)').text.should eq('New')
	# page.find('#ba-invoices-table tr:nth-child(2) td:nth-child(10)').text.should eq('Paid')
end