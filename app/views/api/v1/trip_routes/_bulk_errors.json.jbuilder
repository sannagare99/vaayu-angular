json.success false
json.errors(@trip_routes) do |trip_route|
  unless trip_route.errors.blank?
    json.trip_route_id trip_route.id
    json.error_messages trip_route.errors.full_messages
  end
end
