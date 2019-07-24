SimpleCov.start 'rails' do
  merge_timeout 15000

  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  
  add_filter "/test/"
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/features/"
  add_filter "/app/views/"
  add_filter "/app/assets/"
  add_filter "/app/channels/"
  add_filter "/app/controllers/api/"
  add_filter "/app/datatables/"
  add_filter "/app/helpers/"
  add_filter "/app/mailers/"
  add_filter "/app/presenters/"
  add_filter "/app/workers/"
  add_filter "/lib/"

end
