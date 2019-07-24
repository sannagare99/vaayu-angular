class Operator < ApplicationRecord
  extend AdditionalFinders
  include UserData

  has_one :user, :as => :entity, :dependent => :destroy
  belongs_to :logistics_company

  validates :pan, presence: true, uniqueness: true, length: { is: 10 }
  validates :tan, presence: true, uniqueness: true, length: { is: 10 }
  validates :legal_name, presence: true
  validates :hq_address, presence: true
  validates :service_tax_no, length: { is: 15 }
  validates :logistics_company, presence: true

end
