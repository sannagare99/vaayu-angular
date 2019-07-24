class LogisticsCompany < ApplicationRecord
  extend AdditionalFinders
  DATATABLE_PREFIX = 'company'

  has_many :operators, :dependent => :destroy
  has_many :drivers, :dependent => :destroy

  has_many :employee_companies, :dependent => :destroy
  has_many :business_associates

  validates :name, presence: true

end
