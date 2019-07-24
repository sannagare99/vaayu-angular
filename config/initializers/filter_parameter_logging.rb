# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :phone,
	:emergency_contact_phone, :offline_phone, :admin_phone,
	:email,:admin_email,:managers_email_id,
	:licence_number]
