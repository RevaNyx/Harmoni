Rails.application.config.middleware.use OmniAuth::Builder do
    # Allow GET and POST for OmniAuth callbacks
    OmniAuth.config.allowed_request_methods = [:get, :post]
  
    # Set the full host explicitly for OmniAuth
    OmniAuth.config.full_host = "http://localhost:3000"
  
    # Silence the warning about GET requests
    OmniAuth.config.silence_get_warning = true
  
    # Define the Cronofy provider
    provider :cronofy,
             Rails.application.credentials.dig(:cronofy, :client_id),
             Rails.application.credentials.dig(:cronofy, :client_secret),
             provider_ignores_state: false, # Enable state validation for CSRF protection
             scope: 'read_account read_events create_event delete_event',
             redirect_uri: Rails.application.credentials.dig(:cronofy, :redirect_uri) || 'http://localhost:3000/auth/cronofy/callback'
  
    # Debugging: log the Cronofy redirect URI for confirmation
    Rails.logger.debug "Cronofy Redirect URI: #{Rails.application.credentials.dig(:cronofy, :redirect_uri)}"
  end
  