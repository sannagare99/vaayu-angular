class BaInvoice < ApplicationRecord
  extend AdditionalFinders
  include AASM

  DATATABLE_PREFIX = 'ba_invoice'

  belongs_to :company, polymorphic: true
  has_many :invoice_attachments
  has_many :ba_trip_invoices, :dependent => :destroy

  aasm :column => :status do
    state :created, :initial => true
    state :approved
    state :dirty
    state :paid

    event :pay do
      transitions to: :paid
    end

    event :approve do
      transitions to: :approved
    end

    event :dirty do
      transitions to: :dirty
    end      

    event :new do
      transitions to: :created
    end      
  end

end
