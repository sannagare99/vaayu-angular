class EmployeeCluster < ApplicationRecord
  belongs_to :driver

  has_one :trip
  has_many :employee_trips, dependent: :nullify
  has_many :cluster_vehicles, dependent: :destroy

  validates :date, presence: true
end
