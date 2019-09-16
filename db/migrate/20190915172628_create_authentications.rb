class CreateAuthentications < ActiveRecord::Migration[5.0]
  def change
    create_table :authentications do |t|
      t.string :api_key
      t.text :access_token

      t.timestamps
    end
  end
end
