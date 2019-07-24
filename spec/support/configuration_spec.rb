require 'rspec/expectations'

RSpec.configure do |config|
  api_keys = [
      'AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UE', 'AIzaSyA-gWYoE22krKLhHVmhqv-Q_Egx45lz5aE',
      'AIzaSyCrS5K-MGkmMulh4Z_Uc7LgvIMaEw742sU', 'AIzaSyCQppUMBrKU8119arAs8W51Ilm5ohnoQlc',
      'AIzaSyB-Pjd9z_a44f_mMFSVPO6VlarVQblzuHU', 'AIzaSyDMrkZInC1vGbLCNBsi76R4cRFkbo2bt7c',
      'AIzaSyBnaMV5Ej_3CbVPG6axYJIuJ_lXsmCBEGA', 'AIzaSyBmJLXt5QcObpe64UP7jXc6l7syLFWSzo4',
      'AIzaSyDA-wYjRVyLWa82HmQcLlfSKhJG_cHufls', 'AIzaSyCk2qdrrA9QHPtgmiz4MioiXfl61jtVk6s',
      'AIzaSyDdAFbNdSb7A44_qenuI5cghfSGr-gqwuY', 'AIzaSyBlDg_eZT9pjqfS9cJHmTvXedFk1xa20cg',
      'AIzaSyDP2M4m2bPOJyjJRGDPbTgMEmGUMrHWmRs', 'AIzaSyBBwPYqjGPNaGgm4gosPBx8KHXdzowMe5A',
      'AIzaSyCJEZoeUAu67p3KNiPoJDcH5q3m_wcjRqE', 'AIzaSyBijYnEjGIEIqD8IvCk7Er9fnjB-6VeUdw',
      'AIzaSyAgUH2kvWhpKs5JcC3ldwWeBjWZHWTcq-E', 'AIzaSyDM4PS8rJAUmY23EtRB02RQMgJA06qS3vE',
      'AIzaSyAK9sZDWRv6YS75si6e5xsU_hw3ZFKclOE', 'AIzaSyBrb937zPa6DGDLjgP-nnqxSr0-3053IEs',
      'AIzaSyC5CqwFvMrN46nbNhAJNeKQzblRlyX_vj4', 'AIzaSyCjNLsEKRB5qsNIM6cGamM4dBiRkCaq0K8',
      'AIzaSyC9TH2DCcKmWnj2n3HX9KuYQpOhPtFZdac', 'AIzaSyD6wBp_wKqmKfGTrX8gbM0gLzmD-IVCetQ',
      'AIzaSyCMYw9Wp2RC0ToT6GdvZm0W3fFLi2pA2HQ'
  ]
  # Disable trip validations
  config.before do
    ENV["ENALBE_GUARD_PROVISIONGING"] = nil
    ENV["GOOGLE_MAPS_API_KEY"] = api_keys.shuffle.first

    allow_any_instance_of(Trip).to receive(:check_if_valid_trip).and_return('passed')
  end
end