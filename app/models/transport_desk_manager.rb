class TransportDeskManager < ApplicationRecord
  extend AdditionalFinders
  include UserData

  DATATABLE_PREFIX = 'transport_desk_manager_manager'

  has_one :user, :as => :entity, :dependent => :destroy
  belongs_to :employee_company

  validates :employee_company, presence: true

end