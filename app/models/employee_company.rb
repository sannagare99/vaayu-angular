class EmployeeCompany < ApplicationRecord
  extend AdditionalFinders
  DATATABLE_PREFIX = 'company'

  enum invoice_frequency: [:day, :week, :month], _suffix: true
  enum pay_period: [:trip, :day, :week, :month], _suffix: true

  belongs_to :logistics_company

  has_many :invoices, :as => :company
  has_many :sites
  has_many :employees, :dependent => :destroy
  has_many :employers, :dependent => :destroy

  #validates :logistics_company, presence: true
  validates :name, presence: true

  def self.invoice_frequency_type
    [['Day', 'day'], ['Week', 'week'], ['Month', 'month']]
  end

  def self.pay_period_type
    [['Trip', 'trip'], ['Day', 'day'], ['Week', 'week'], ['Month', 'month']]
  end

end
