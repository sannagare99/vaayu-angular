class OperatorShiftManager < ApplicationRecord
  include UserData

  has_one :user, as: :entity, dependent: :destroy
  has_many :shift_times, foreign_key: :shift_manager_id, class_name: "OperatorShiftManagerTime"
  belongs_to :logistics_company

  validates :pan, presence: true, uniqueness: true, length: { is: 10 }
  validates :tan, presence: true, uniqueness: true, length: { is: 10 }
  validates :legal_name, presence: true
  validates :hq_address, presence: true
  validates :service_tax_no, length: { is: 15 }
  validates :logistics_company, presence: true

  attr_accessor :sm_type, :site_id

  def sites
    Site.joins(:employee_company).where("employee_companies.logistics_company_id =? ", self.logistics_company_id).map { |x| [x.name, x.id] }
  end
end
