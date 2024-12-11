Rails.application.config.middleware.use OmniAuth::Builder do
    provider :cronofy, 
             Rails.application.credentials.dig(:cronofy, :client_id), 
             Rails.application.credentials.dig(:cronofy, :client_secret), 
             scope: 'read_events create_event',
             redirect_uri: ENV['CRONOFY_REDIRECT_URI']
  end