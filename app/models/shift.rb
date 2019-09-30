class Shift < ApplicationRecord
  include AASM

  has_many :employee_trips
  has_many :shift_users
  has_many :users, through: :shift_users
  belongs_to :sites
  
  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :start_end_time_format

  aasm column: :status do
    state :inactive, initial: true
    state :active

    event :activate do
      transitions from: :inactive, to: :active
    end

    event :deactivate do
      transitions from: :active, to: :inactive
    end
  end

  def start_end_time_format
    [:start_time, :end_time].each do |inp|
      errors.add(inp, "Invalid time") unless /^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/ =~ self.send(inp)
    end
  end
end
