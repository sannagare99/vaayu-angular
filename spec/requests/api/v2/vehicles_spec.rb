require 'rails_helper'

RSpec.describe "API::V2::Vehicles", type: :request do
  describe "GET /api/v2/vehicles" do
    it "works! (now write some real specs)" do
      get api_v2_vehicles_path
      expect(response).to have_http_status(200)
    end
  end
end
