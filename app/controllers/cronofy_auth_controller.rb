require 'cronofy'

class CronofyAuthController < ApplicationController
  before_action :authenticate_user!

  # Step 1: Redirect user to Cronofy for OAuth authorization
  def connect
    state = SecureRandom.hex(16) # Generate secure random state
    session[:omniauth_state] = state # Save state to session for CSRF protection

    cronofy_auth_url = "https://app.cronofy.com/oauth/v2/authorize"
    client_id = Rails.application.credentials.dig(:cronofy, :client_id)
    redirect_uri = "#{request.base_url}/auth/cronofy/callback"
    scope = "read_account read_events create_event delete_event"

    # Build the authorization URL
    auth_url = "#{cronofy_auth_url}?client_id=#{client_id}" \
               "&redirect_uri=#{CGI.escape(redirect_uri)}" \
               "&response_type=code&scope=#{CGI.escape(scope)}&state=#{state}"

    Rails.logger.info "Generated Cronofy Auth URL: #{auth_url}"
    redirect_to auth_url, allow_other_host: true
  end

  # Step 2: Handle Cronofy OAuth callback
  def callback
    Rails.logger.info "Callback Params: #{params.inspect}"
    Rails.logger.info "Session State: #{session[:omniauth_state]}"

    # Verify state to protect against CSRF
    # if params[:state] != session[:omniauth_state]
    #   Rails.logger.error "State mismatch! Possible CSRF attack."
    #   flash[:alert] = "Authorization failed. Please try again."
    #   return redirect_to dashboard_path
    # end

    # Exchange authorization code for access token
    if params[:code].present?
      begin
        client = Cronofy::Client.new(
          client_id: Rails.application.credentials.dig(:cronofy, :client_id),
          client_secret: Rails.application.credentials.dig(:cronofy, :client_secret)
        )

        response = client.get_token_from_code(
          params[:code],
          redirect_uri: "#{request.base_url}/auth/cronofy/callback"
        )

        Rails.logger.info "Cronofy Token Response: #{response.inspect}"

        # Update user with tokens
        current_user.update!(
          access_token: response.access_token,
          refresh_token: response.refresh_token,
          token_expiration: Time.current + response.expires_in.seconds
        )

        flash[:notice] = "Successfully connected to Cronofy!"
        redirect_to dashboard_path
      rescue StandardError => e
        Rails.logger.error "Cronofy OAuth Error: #{e.message}"
        flash[:alert] = "Failed to connect to Cronofy. Please try again."
        redirect_to dashboard_path
      end
    # else
    #   Rails.logger.error "Authorization code missing in callback params."
    #   flash[:alert] = "Authorization failed. Please try again."
    #   redirect_to dashboard_path
    end
  end
end
