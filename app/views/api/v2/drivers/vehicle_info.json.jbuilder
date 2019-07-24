json.success true
json.vehicles(@vehicles) do |vehicle|
  json.partial! 'api/v2/vehicles/vehicle', locals: { vehicle: vehicle }
end