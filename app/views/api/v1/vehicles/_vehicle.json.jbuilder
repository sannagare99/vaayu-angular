json.extract! @vehicle, :id, :plate_number, :make, :model, :colour, :seats, :make_year, :status
json.photo @vehicle.photo.url
