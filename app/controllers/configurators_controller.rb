class ConfiguratorsController < ApplicationController
  include ConfiguratorsHelper
  load_and_authorize_resource

  def index
    render json: { sEcho: 0, iTotalRecords: 1, iTotalDisplayRecords: 1, aaData: [{s_no: 1, name: Site.first.name}] }
  end

  def show
    @configurators = Configurator.all
  end

  def edit
    @configurations = Configurator.all
    @custom_configs = GoogleAPIKey.working
  end

  def update
    Configurator.update_configuration(configurator_params)
    Configurator.update_google_api(google_params)
    redirect_to configurators_path
  end

  def update_config
    Configurator.update_configuration(configurator_params[:shift_policies])    
    redirect_to configurators_path(anchor: "general_settings")
  end

  def update_system_config
    Configurator.update_configuration(configurator_params[:shift_policies])
    Configurator.update_google_api(google_params)
    redirect_to configurators_path(anchor: "system_settings")
  end

  private

  def configurator_params
    params.require(:configurator).permit!
  end

  def google_params
    params.require(:google_configs).permit!
  end
end
