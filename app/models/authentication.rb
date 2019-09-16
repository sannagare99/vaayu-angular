class Authentication < ApplicationRecord
	before_create :generate_access_token

	private
  
  def generate_access_token
    begin
      self.x_api_key = SecureRandom.hex
    end while self.class.exists?(x_api_key: x_api_key)
  end
end
