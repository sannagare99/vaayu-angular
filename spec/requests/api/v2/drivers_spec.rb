require 'rails_helper'

RSpec.describe "API::V2::Drivers", type: :request do
  describe "GET /api/v2/drivers" do
    it "works! (now write some real specs)" do
      get api_v2_drivers_path
      expect(response).to have_http_status(200)
    end
  end
end
