json.extract! @driver, :user_id, :username, :email, :f_name, :m_name, :l_name, :phone
json.profile_picture @driver.full_avatar_url

json.operating_organization do
  json.name @driver.operating_organization_name
  json.phone @driver.operating_organization_phone
end

# @TODO: remove, it's deprecated
json.administrative_organization do
  json.name nil
  json.phone nil
end
