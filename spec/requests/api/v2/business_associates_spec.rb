require 'rails_helper'

RSpec.describe "API::V2::BusinessAssociates", type: :request do
  describe "GET /api/v2/business_associates" do
    it "works! (now write some real specs)" do
      get api_v2_business_associates_path
      expect(response).to have_http_status(200)
    end
  end
end
