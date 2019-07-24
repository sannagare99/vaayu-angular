class Device < ApplicationRecord
  enum status: [:active, :available, :broke]

  belongs_to :driver

  validates :device_id, presence: true
  validates :make, presence: true
  validates :model, presence: true
  validates :os, presence: true
  validates :os_version, presence: true
  validates :driver, presence: true
end
