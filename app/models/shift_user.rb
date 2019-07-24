class ShiftUser < ApplicationRecord
  belongs_to :shift
  belongs_to :user
end
