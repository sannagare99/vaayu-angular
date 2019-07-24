class AddDisabledAtToGoogleAPIKeys < ActiveRecord::Migration[5.0]
  def change
    add_column :google_api_keys, :disabled_at, :datetime
  end
end
