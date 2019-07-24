class EmployerShiftManager < ApplicationRecord
  include UserData

  has_one :user, as: :entity, dependent: :destroy
  has_many :shift_times, foreign_key: :shift_manager_id, class_name: "EmployerShiftManagerTime"
  belongs_to :employee_company

  validates :employee_company, presence: true

  attr_accessor :sm_type, :site_id

  def sites
    employee_company.sites.map { |x| [x.name, x.id] }
  end
end
