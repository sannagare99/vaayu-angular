class CreateEmployeeTripIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_trip_issues do |t|
      t.integer :issue
      t.belongs_to :employee_trip
    end
    add_column :employee_trips, :rating, :integer
    add_column :employee_trips, :rating_feedback, :text
  end
end
