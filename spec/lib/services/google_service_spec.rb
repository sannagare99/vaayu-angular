require 'rails_helper'

RSpec.describe GoogleService do
  setup do
    create(:google_api_key, key: 'AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UE')
    create(:google_api_key, key: 'AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UF')
    create(:google_api_key, key: 'AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UG')
  end

  context 'No Error' do
    it 'should make geocode service call successfully' do
      expect {
        subject.geocode('Kanakpura Road')
      }.to_not raise_error(GoogleMapsService::Error::RateLimitError)
      expect(subject.client.key).to eq('AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UE')
    end
  end

  context 'RateLimitError' do
    it 'should change google maps api key' do
      # Mock GoogleMapsService Client calls to throw rate limit errors on every
      # 1 out of 3 calls for simulating rate limit error scenarios
      counter = 0
      allow_any_instance_of(GoogleMapsService::Client)
        .to receive(:geocode) do
        (counter += 1) % 3 == 1 ? raise(GoogleMapsService::Error::RateLimitError) : 1
      end
      expect(subject.client.key).to eq('AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UE')

      # First call would be rate limited
      # hence we would mark the GoogleAPIKey as rate_limited and get the next
      # available key and retry with that key (That will be the second call)
      subject.geocode('Kanakpura Road')
      expect(GoogleAPIKey.find_by(key: 'AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UE').rate_limited?).to be true
      expect(subject.client.key).to eq('AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UF')

      # Third call would go through without a rate limit error
      subject.geocode('Kanakpura Road')
      expect(subject.client.key).to eq('AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UF')

      # Fourth call would be rate limited
      # again we will do as in the first call
      subject.geocode('Kanakpura Road')
      expect(GoogleAPIKey.find_by(key: 'AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UF').rate_limited?).to be true
      expect(subject.client.key).to eq('AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UG')
    end
  end
end
