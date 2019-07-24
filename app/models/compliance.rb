class Compliance < ApplicationRecord
  enum compliance_type: [:quality, :behaviour, :document, :safety]
  enum modal_type: [:driver, :vehicle]
  enum status: [:active, :completed]

  belongs_to :driver
  belongs_to :vehicle
end
