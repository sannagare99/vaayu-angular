class EmployeeTripIssue < ApplicationRecord
  belongs_to :employee_trip

  enum issue: [ :not_timely, :unsafe, :dirty ]

  validates :issue, uniqueness: { scope: :employee_trip }
end
