class Zone < ApplicationRecord
  extend AdditionalFinders
  DATATABLE_PREFIX = 'zone'

  has_many :users

  validates :name, numericality: { only_integer: true }, presence: true

end
