class GoogleAPIKey < ApplicationRecord
  include AASM

  aasm column: 'status' do
    state :working, initial: true
    state :rate_limited
    state :disabled

    after_all_transitions :update_timestamp

    event :rate_limit do
      transitions from: :working, to: :rate_limited
    end

    event :disable do
      transitions to: :disabled
    end
  end

  private

  def update_timestamp
    self.update("#{aasm.to_state}_at": Time.now)
  end
end
