class IngestManifestJob < ApplicationRecord
  include AASM

  aasm column: 'status' do
    state :queued, initial: true
    state :processing
    state :failed
    state :completed
    state :cancelled

    event :process do
      transitions from: :queued, to: :processing
    end

    event :fail do
      transitions from: :processing, to: :failed
    end

    event :complete do
      transitions from: :processing, to: :completed
    end

    event :cancel do
      transitions from: [:queued, :processing], to: :cancelled
    end
  end

  has_attached_file :file, s3_protocol: 'http'
  validates_attachment :file, presence: true, content_type: {
    content_type: /vnd\.openxmlformats-officedocument\.spreadsheetml\.sheet/,
    message: 'only xlsx files'
  }

  has_attached_file :error_file, s3_protocol: 'http'
  validates_attachment :error_file, content_type: {content_type: /text|csv/}

  belongs_to :user
end
