json.array!(@trips) do |trip|
  json.partial! 'api/v1/trips/trip_short', locals: { trip: trip }
end