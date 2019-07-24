module UserData
  extend ActiveSupport::Concern

  included do
    delegate :id, to: :user, prefix: true
    delegate :username, :f_name, :m_name, :l_name, :email, :phone, :full_name, :avatar, :full_avatar_url, :avatar_file_name,
             to: :user, allow_nil: true

  end
end