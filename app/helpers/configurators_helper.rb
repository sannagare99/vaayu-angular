module ConfiguratorsHelper
  def get_label_and_val(req_type)
    conf = @configurators.select { |x| x.request_type == req_type }.first
    return nil unless conf.present?
    conf
  end

  Configurator.all.each do |conf|
    define_method conf.request_type.to_sym do
      get_label_and_val(conf.request_type)
    end
  end

  def generate_option(conf_options)
    conf_options.map { |option_name| [option_name, option_name] }
  end

  def get_all_google_key
    GoogleAPIKey.working
  end
end
