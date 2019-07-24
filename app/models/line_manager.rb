class LineManager < ApplicationRecord
  extend AdditionalFinders
  include UserData

  DATATABLE_PREFIX = 'line_manager'

  has_one :user, :as => :entity, :dependent => :destroy
  has_many :employees
  belongs_to :employee_company

  validates :employee_company, presence: true

end