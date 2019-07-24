class AddRelationsToBa < ActiveRecord::Migration[5.0]
  def change
    add_reference :business_associates, :logistics_company, index: true

    add_column :business_associates, :profit_centre, :string
    add_column :business_associates, :agreement_date, :datetime

    add_column :employee_companies, :profit_centre, :string
    add_column :employee_companies, :agreement_date, :datetime
  end
end
