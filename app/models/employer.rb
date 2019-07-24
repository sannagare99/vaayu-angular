class Employer < ApplicationRecord
  extend AdditionalFinders
  include UserData

  DATATABLE_PREFIX = 'employer'

  has_one :user, :as => :entity, :dependent => :destroy
  belongs_to :employee_company

  validates :pan, presence: true, uniqueness: true, length: { is: 10 }
  validates :tan, presence: true, uniqueness: true, length: { is: 10 }
  validates :legal_name, presence: true
  validates :hq_address, presence: true
  validates :service_tax_no, length: { is: 15 }
  validates :employee_company, presence: true

end
