class ChangeDatatypeToInsuranceDocUrl < ActiveRecord::Migration[5.0]
  def up
    change_column :vehicles, :insurance_doc_url, :string
  end

  def down
    change_column :vehicles, :insurance_doc_url, :date
  end
end
