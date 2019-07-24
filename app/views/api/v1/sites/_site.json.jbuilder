json.extract! site, :id, :name, :address
json.location do
  json.latitude site.latitude
  json.longitude site.longitude
end