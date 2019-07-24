class AddAppLinkDataToConfigurators < ActiveRecord::Migration[5.0]
  def change
    new_conf_sequence = [{request_type: "rider_app_android", value: "http://bit.ly/2Lzh3sC", conf_type: "string",display_name: ""},
      {request_type: "rider_app_ios", value: "https://apple.co/2LqdtC0", conf_type: "string",display_name: ""},
      {request_type: "provider_app_android", value: "http://bit.ly/2Lxy4TY", conf_type: "string",display_name: ""}]

    new_conf_sequence.each do |conf|
      Configurator.create_with({value: conf[:value], conf_type: conf[:conf_type], options: conf[:options], display_name: conf[:display_name]}).find_or_create_by(request_type: conf[:request_type])
    end
  end
end
