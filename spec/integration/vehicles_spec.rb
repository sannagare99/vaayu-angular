# spec/integration/pets_spec.rb
require 'swagger_helper'

describe 'Vehicles API' do

  path '/api/v2/vehicles' do

    post 'Creates a vehicle' do
      tags 'Vehicles'
      consumes 'application/json'
      parameter business_associate_id: :vehicle, in: :body, schema: {
        type: :object,
        properties: {
          business_associate_id: {type: :integer},
          plate_number: { type: :string },
          model: { type: :string },
          seats:  {type: :integer},
          ac: { type: :string },
          fuel_type: { type: :string },
          colour: { type: :string},
          fitness_doc_url: { type: :string }
        },
        required: [ 'business_associate_id', 'plate_number', 'model' ]
      }

      response '201', 'Vehicle created' do
        let(:vehicle) { { business_associate_id: 1, plate_number: '12345678901234', model: "new", seats: 10, ac: true , fuel_type: "Patrol" , colour: 'Red', fitness_doc_url: 'http://localhost:3000/api-docs/test.jpg' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:vehicle) { { licence_number: '12345678901234' } }
        run_test!
      end
    end
  end

  path '/api/v2/vehicles/{id}' do

    delete 'Delete a vehicle' do
      tags 'Vehicles'
      produces 'application/json', 'application/xml'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'Vehicle deleted' do
        schema type: :object,
          properties: {
          business_associate_id: {type: :integer},
          plate_number: { type: :string },
          model: { type: :string },
          seats:  {type: :integer},
          ac: { type: :string },
          fuel_type: { type: :string },
          colour: { type: :string},
          fitness_doc_url: { type: :string }
        },
          required: [ 'id', 'business_associate_id', 'plate_number' ]

        let(:id) { }
        run_test!
      end

      response '404', 'Vehicle not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v2/vehicles/{id}' do

    get 'Retrieves a vehicle' do
      tags 'Vehicles'
      produces 'application/json', 'application/xml'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'Vehicle found' do
        schema type: :object,
          properties: {
          business_associate_id: {type: :integer},
          plate_number: { type: :string },
          model: { type: :string },
          seats:  {type: :integer},
          ac: { type: :string },
          fuel_type: { type: :string },
          colour: { type: :string},
          fitness_doc_url: { type: :string }
        },
          required: [ 'id', 'business_associate_id', 'plate_number' ]

        let(:id) { Vehicle.create(business_associate_id: 'foo', plate_number: '3232323', fitness_doc_url: 'http://example.com/avatar.jpg').id }
        run_test!
      end

      response '404', 'Vehicle not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v2/vehicles' do

    get 'Retrieves vehicles' do
      tags 'Vehicles'
      produces 'application/json', 'application/xml'
      # parameter name: :id, :in => :path, :type => :string

      response '200', 'Vehicles found' do
        schema type: :object,
          properties: {
          business_associate_id: {type: :integer},
          plate_number: { type: :string },
          model: { type: :string },
          seats:  {type: :integer},
          ac: { type: :string },
          fuel_type: { type: :string },
          colour: { type: :string},
          fitness_doc_url: { type: :string }
        },
          required: [ 'id', 'business_associate_id', 'licence_number' ]

        # let(:id) { Pet.create(name: 'foo', status: 'bar', photo_url: 'http://example.com/avatar.jpg').id }
        run_test!
      end
      response '404', 'Vehicle not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

end
