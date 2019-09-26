class BusinessAssociate < ApplicationRecord
  extend AdditionalFinders
  DATATABLE_PREFIX = 'ba'
  enum invoice_frequency: [:day, :week, :month], _suffix: true
  enum pay_period: [:trip, :day, :week, :month], _suffix: true


  has_many :invoices, :as => :company
  has_many :drivers
  has_many :vehicles
  # serialize :gstDocs, JSON

  belongs_to :logistics_company

  # validates :pan, presence: true, uniqueness: true, length: { is: 10 }
  # validates :tan, presence: true, uniqueness: true, length: { is: 10 }
  # validates :name, presence: true
  # validates :legal_name, presence: true
  # validates :hq_address, presence: true
  # validates :service_tax_no, length: { is: 15 }
  # validates :pay_period, numericality: { less_than: 31 }

  def self.invoice_frequency_type
    [['Day', 'day'], ['Week', 'week'], ['Month', 'month']]
  end

  def self.pay_period_type
    [['Trip', 'trip'], ['Day', 'day'], ['Week', 'week'], ['Month', 'month']]
  end


end
