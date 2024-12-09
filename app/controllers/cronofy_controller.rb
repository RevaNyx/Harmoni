class CronofyController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_connected, only: [:calendars]
  
    # Redirects the user to Cronofy for authorization
    def connect
      client = Cronofy::Client.new(
        client_id: ENV['CRONOFY_CLIENT_ID'],
        client_secret: ENV['CRONOFY_CLIENT_SECRET']
      )
  
      authorization_url = client.user_auth_link(
        redirect_uri: auth_callback_url,
        scope: 'read_account read_events create_event delete_event'
      )
  
      # Log the generated URL for debugging
      Rails.logger.info("Generated Authorization URL: #{authorization_url}")
  
      # Redirect to Cronofy for authorization
      redirect_to authorization_url, allow_other_host: true and return
    end
  
    # Handles the OAuth callback after user authorization
    def callback
      Rails.logger.info("Callback Params: #{params.inspect}")
      code = params[:code]
  
      if code.present?
        begin
          Rails.logger.info("Initializing Cronofy client for token exchange...")
          client = Cronofy::Client.new(
            client_id: ENV['CRONOFY_CLIENT_ID'],
            client_secret: ENV['CRONOFY_CLIENT_SECRET']
          )
  
          Rails.logger.info("Exchanging authorization code for tokens...")
          response = client.get_token_from_code(
            code,
            redirect_uri: auth_callback_url
          )
  
          Rails.logger.info("Token Response: #{response.inspect}")
  
          Rails.logger.info("Saving tokens to the user record...")
          if current_user.update(
            access_token: response.access_token,
            refresh_token: response.refresh_token,
            token_expiration: Time.now + response.expires_in.seconds
          )
            Rails.logger.info("User tokens updated successfully!")
            flash[:notice] = "Successfully connected to Cronofy!"
            redirect_to dashboard_path
          else
            Rails.logger.error("Failed to update user: #{current_user.errors.full_messages}")
            flash[:alert] = "Failed to save tokens. Please try again."
            redirect_to dashboard_path
          end
        rescue Cronofy::BadRequestError => e
          Rails.logger.error("Token Exchange Failed: #{e.message}")
          flash[:alert] = "Failed to connect to Cronofy. Please try again."
          redirect_to dashboard_path
        end
      else
        Rails.logger.error("Authorization code missing in callback params.")
        flash[:alert] = "Invalid authorization code."
        redirect_to dashboard_path
      end
    end
  
    # Fetches and displays a list of calendars
    def calendars
      @calendars = []
  
      unless current_user.connected?
        Rails.logger.info("User #{current_user.id} is not connected to Cronofy.")
        flash[:alert] = "Please connect your Cronofy account."
        return redirect_to auth_cronofy_path
      end
  
      begin
        refresh_token_if_needed(current_user)
        client = cronofy_client(current_user)
        @calendars = client.list_calendars
  
        # Log fetched calendars
        Rails.logger.info("Fetched Calendars for user #{current_user.id}: #{@calendars.inspect}")
      rescue Cronofy::AuthenticationFailureError => e
        Rails.logger.error("Cronofy Authentication Error: #{e.message}")
        flash[:alert] = "Your connection has expired. Please reconnect."
        redirect_to auth_cronofy_path
      rescue StandardError => e
        Rails.logger.error("Cronofy Error: #{e.message}")
        flash[:alert] = "Unable to fetch calendars. Please try again later."
      end
    end
  
    private
  
    # Ensures the user is connected
    def ensure_connected
      unless current_user.connected?
        Rails.logger.info("User #{current_user.id} attempted to access without connection.")
        flash[:alert] = "Please connect your account."
        redirect_to auth_cronofy_path
      end
    end
  
    # Initializes the Cronofy client
    def cronofy_client(user = nil)
      Cronofy::Client.new(
        client_id: ENV['CRONOFY_CLIENT_ID'],
        client_secret: ENV['CRONOFY_CLIENT_SECRET'],
        data_center: ENV['CRONOFY_DATA_CENTER'] || 'us',
        access_token: user&.access_token,
        refresh_token: user&.refresh_token
      )
    end
  
    # Refreshes the user's token if expired
    def refresh_token_if_needed(user)
      if user.token_expiration < Time.now
        Rails.logger.info("Refreshing token for user #{user.id}")
        client = Cronofy::Client.new(
          client_id: ENV['CRONOFY_CLIENT_ID'],
          client_secret: ENV['CRONOFY_CLIENT_SECRET']
        )
        response = client.refresh_access_token(refresh_token: user.refresh_token)
  
        if user.update(
             access_token: response.access_token,
             refresh_token: response.refresh_token,
             token_expiration: Time.now + response.expires_in.seconds
           )
          Rails.logger.info("Token refreshed successfully for user #{user.id}")
        else
          Rails.logger.error("Failed to update tokens after refresh for user #{user.id}")
        end
      else
        Rails.logger.info("Token still valid for user #{user.id}")
      end
    rescue Cronofy::AuthenticationFailureError => e
      Rails.logger.error("Failed to refresh token: #{e.message}")
      raise
    end
  
    # Generates the OAuth callback URL dynamically
    def auth_callback_url
      "#{request.base_url}/auth/cronofy/callback"
    end
  end
  