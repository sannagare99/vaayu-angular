# spec/integration/pets_spec.rb
require 'swagger_helper'

describe 'Vehicles API' do

  path '/api/v2/vehicles' do

    post 'Creates a vehicle' do
      tags 'Vehicles'
      consumes 'application/json'
      parameter business_associate: :vehicle, in: :body, schema: {
        type: :object,
        properties: {
          business_associate: {type: :integer},
          plate_number: { type: :string },
          model: { type: :string },
          seats:  {type: :integer},
          ac: { type: :string },
          fuel_type: { type: :string },
          colour: { type: :string},
          fitness_doc_url: { type: :string }
        },
        required: [ 'business_associate', 'plate_number', 'model' ]
      }

      response '201', 'Vehicle created' do
        let(:vehicle) { { business_associate: 'Raj sharma', plate_number: '12345678901234', model: "new", seats: 10, ac: true , fuel_type: "Patrol" , colour: 'Red', fitness_doc_url: 'http://localhost:3000/api-docs/test.jpg' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:vehicle) { { licence_number: '12345678901234' } }
        run_test!
      end
    end
  end


end
