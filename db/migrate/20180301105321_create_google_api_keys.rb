class CreateGoogleAPIKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :google_api_keys do |t|
      t.string :key
      t.string :status

      t.datetime :rate_limited_at

      t.timestamps
    end
  end
end
