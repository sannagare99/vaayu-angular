json.extract! trip, :id, :status, :trip_type, :real_duration
json.approximate_distance trip.scheduled_approximate_distance
json.start_date trip.start_date.to_i
json.date trip.scheduled_date.to_i
json.site_name trip.site_name