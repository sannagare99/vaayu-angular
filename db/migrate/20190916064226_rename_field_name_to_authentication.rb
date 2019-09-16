class RenameFieldNameToAuthentication < ActiveRecord::Migration[5.0]
  def change
  	rename_column :authentications, :api_key, :portal
  	rename_column :authentications, :access_token, :x_api_key
  end
end
