SecureHeaders::Configuration.default do |config|
  # config.cookies = {
  #   secure: true, # mark all cookies as "Secure"
  #   httponly: true, # mark all cookies as "HttpOnly"
  #   samesite: {
  #     lax: true # mark all cookies as SameSite=lax
  #   }
  # }
  # Add "; preload" and submit the site to hstspreload.org for best protection.
  config.x_frame_options = "sameorigin"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = %w(origin-when-cross-origin strict-origin-when-cross-origin)
  config.csp_report_only = {
   default_src: ["'self'"],
   child_src: ["'self'"],
   form_action: ["'self'"],
   block_all_mixed_content: true,
   connect_src: ["'self'", 'ws:'],
   font_src: ["'self'", 'data:', 'fonts.gstatic.com'],
   img_src: ["'self'", 'data:', '*.gstatic.com', '*.amazonaws.com', '*.google.com'],
   media_src: ["'self'"],
   object_src: ["'none'"],
   script_src: ["'self'",'*.googleapis.com', '*.google.com', 'cdn.rawgit.com', "'unsafe-eval'", "'unsafe-inline'"],
   style_src: ["'self'",'*.googleapis.com', "'unsafe-inline'" ],
   base_uri: ["'self'"],
   report_uri: %w(https://report-uri.io/example-csp)
 }
  config.cookies = SecureHeaders::OPT_OUT
  config.csp = SecureHeaders::OPT_OUT
end
