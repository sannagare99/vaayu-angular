class CreateMllComplianceUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :mll_compliance_users do |t|

      t.timestamps
    end
  end
end
