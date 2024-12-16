class CronofyController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]

  def connect
    state = SecureRandom.hex(16)
    session[:omniauth_state] = state
    redirect_to generate_cronofy_auth_url(state)
  end

  def callback
    if params[:state] != session[:omniauth_state]
      Rails.logger.error("CSRF State Mismatch!")
      redirect_to root_path, alert: "Invalid state parameter. Please try again."
      return
    end

    # Process the callback
    handle_cronofy_callback(params[:code])
  end

  private

  def generate_cronofy_auth_url(state)
    base_url = "https://app.cronofy.com/oauth/v2/authorize"
    query_params = {
      client_id: ENV['CRONOFY_CLIENT_ID'],
      redirect_uri: 'http://localhost:3000/auth/cronofy/callback',
      response_type: 'code',
      scope: 'read_account read_events create_event delete_event',
      state: state
    }
    "#{base_url}?#{query_params.to_query}"
  end

  def handle_cronofy_callback(code)
    client = Cronofy::Client.new(
      client_id: ENV['CRONOFY_CLIENT_ID'],
      client_secret: ENV['CRONOFY_CLIENT_SECRET']
    )

    response = client.get_token_from_code(code, redirect_uri: 'http://localhost:3000/auth/cronofy/callback')
    current_user.update!(
      access_token: response.access_token,
      refresh_token: response.refresh_token,
      token_expiration: Time.now + response.expires_in.seconds
    )
    redirect_to dashboard_path, notice: "Cronofy successfully connected!"
  end
end
