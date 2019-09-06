# spec/integration/pets_spec.rb
require 'swagger_helper'

describe 'Drivers API' do

  path '/api/v2/drivers' do

    post 'Creates a driver' do
      tags 'Drivers'
      consumes 'application/json'
      parameter business_associate: :driver, in: :body, schema: {
        type: :object,
        properties: {
          business_associate: {type: :integer},
          licence_number: { type: :string },
          f_name: { type: :string },
          aadhaar_mobile_number: { type: :string },
          date_of_birth: { type: :string },
          marital_status: { type: :string },
          gender: { type: :string},
          blood_group: { type: :string }
        },
        required: [ 'licence_number', 'f_name', 'aadhaar_mobile_number', 'business_associate', 'aadhaar_mobile_number', 'date_of_birth', 'marital_status', 'gender' , 'blood_group' ]
      }

      response '201', 'Driver created' do
        let(:driver) { { business_associate: 'Raj sharma', licence_number: '12345678901234', f_name: 'Sandeep', aadhaar_mobile_number: '09754431024', date_of_birth: '2019-08-19', marital_status: 'Married', gender: 'Male', blood_group: 'A+' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:driver) { { licence_number: '2121212121' } }
        run_test!
      end
    end
  end

  path '/api/v2/drivers/{id}' do

    get 'Retrieves a driver' do
      tags 'Drivers'
      produces 'application/json', 'application/xml'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'Driver found' do
        schema type: :object,
          properties: {
          business_associate: {type: :integer},
          licence_number: { type: :string },
          f_name: { type: :string },
          aadhaar_mobile_number: { type: :string },
          date_of_birth: { type: :string },
          marital_status: { type: :string },
          gender: { type: :string},
          blood_group: { type: :string }
        },
          required: [ 'id', 'business_associate', 'licence_number' ]

        let(:id) { Pet.create(name: 'foo', status: 'bar', photo_url: 'http://example.com/avatar.jpg').id }
        run_test!
      end

      response '404', 'driver not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v2/drivers' do

    get 'Retrieves drivers' do
      tags 'Drivers'
      produces 'application/json', 'application/xml'
      # parameter name: :id, :in => :path, :type => :string

      response '200', 'Drivers found' do
        schema type: :object,
          properties: {
          business_associate: {type: :integer},
          licence_number: { type: :string },
          f_name: { type: :string },
          aadhaar_mobile_number: { type: :string },
          date_of_birth: { type: :string },
          marital_status: { type: :string },
          gender: { type: :string},
          blood_group: { type: :string }
        },
          required: [ 'id', 'business_associate', 'licence_number' ]

        # let(:id) { Pet.create(name: 'foo', status: 'bar', photo_url: 'http://example.com/avatar.jpg').id }
        run_test!
      end
      response '404', 'driver not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v2/drivers/{id}' do

    delete 'Delete a driver' do
      tags 'Drivers'
      produces 'application/json', 'application/xml'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'Driver deleted' do
        schema type: :object,
          properties: {
          id: :id,
          business_associate: {type: :integer},
          licence_number: { type: :string },
          f_name: { type: :string },
          aadhaar_mobile_number: { type: :string },
          date_of_birth: { type: :string },
          marital_status: { type: :string },
          gender: { type: :string},
          blood_group: { type: :string }
        },
          required: [ 'id', 'business_associate', 'licence_number' ]

        let(:id) { }
        run_test!
      end

      response '404', 'driver not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v2/drivers/search' do

    get 'Search driver or vehicle' do
      tags 'Search driver or vehicle'
      produces 'application/json', 'application/xml'
      parameter type: :id, :in => :type, :type => :string
      parameter name: :licence_number, :in => :path, :type => :string

      response '200', 'Search result' do
        schema type: :object,
          properties: {
          id: :id,
          business_associate: {type: :integer},
          licence_number: { type: :string },
          f_name: { type: :string },
          aadhaar_mobile_number: { type: :string },
          date_of_birth: { type: :string },
          marital_status: { type: :string },
          gender: { type: :string},
          blood_group: { type: :string }
        },
          required: [ 'id', 'f_name', 'licence_number' ]

        let(:id) { }
        run_test!
      end

      response '404', 'Record not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
