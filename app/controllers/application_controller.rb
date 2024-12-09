class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_sidebar_data
  before_action :log_csrf_token
  before_action :ensure_cronofy_token_valid
  protect_from_forgery unless: -> { request.format.json? }
  skip_before_action :verify_authenticity_token, if: -> { request.format.html? }
  # Log the CSRF token for debugging
  def log_csrf_token
    Rails.logger.debug "CSRF Token: #{form_authenticity_token}"
  end
  
  # Redirect to dashboard after sign-in
  def after_sign_in_path_for(resource)
    Rails.logger.info("User #{resource.id} signed in successfully.")
    dashboard_path
  end

  # Refresh Cronofy tokens if expired
  def refresh_cronofy_token(user)
    cronofy = cronofy_client(user)

    begin
      Rails.logger.info("Refreshing Cronofy tokens for User ID: #{user.id}")
      response = cronofy.refresh_access_token(
        refresh_token: user.refresh_token
      )

      # Update the user's tokens and expiration time
      if user.update(
           access_token: response.access_token,
           refresh_token: response.refresh_token,
           token_expiration: Time.now + response.expires_in.seconds
         )
        Rails.logger.info("Successfully refreshed tokens for User ID: #{user.id}")
        true
      else
        Rails.logger.error("Failed to update refreshed tokens for User ID: #{user.id}")
        false
      end
    rescue Cronofy::AuthenticationFailureError => e
      Rails.logger.error("Cronofy token refresh failed for User ID #{user.id}: #{e.message}")
      false
    end
  end

  protected

  # Devise: Permit additional parameters for sign-up and account updates
  def configure_permitted_parameters
    Rails.logger.info("Configuring permitted Devise parameters.")
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :first_name, :last_name, :role_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :username, :first_name, :last_name, :role_id, :access_token, :refresh_token, :token_expiration
    ])
  end

  private

  def load_sidebar_data
    if user_signed_in?
      @appointments = current_user.appointments.upcoming if defined?(Appointment)
      @tasks = current_user.tasks.incomplete if defined?(Task)
    end
  end

  def log_csrf_token
    Rails.logger.info "Expected CSRF Token: #{form_authenticity_token}"
    Rails.logger.info "Received CSRF Token: #{request.headers['X-CSRF-Token']}"
  end



  # Initialize a Cronofy client
  def cronofy_client(user = nil)
    client_id = Rails.application.credentials.dig(:cronofy, :client_id)
    client_secret = Rails.application.credentials.dig(:cronofy, :client_secret)
    data_center = Rails.application.credentials.dig(:cronofy, :data_center) || 'us'

    Rails.logger.info("Initializing Cronofy client for User ID: #{user&.id || 'N/A'}")
    if user&.access_token.present? && user&.refresh_token.present?
      Rails.logger.info("Using User tokens for Cronofy client.")
      Cronofy::Client.new(
        client_id: client_id,
        client_secret: client_secret,
        data_center: data_center,
        access_token: user.access_token,
        refresh_token: user.refresh_token
      )
    else
      Rails.logger.info("No user tokens found; using application-level Cronofy client.")
      Cronofy::Client.new(
        client_id: client_id,
        client_secret: client_secret,
        data_center: data_center
      )
    end
  end

  def ensure_cronofy_token_valid
    return unless current_user&.token_expiration.present?

    if current_user.token_expiration < Time.now
      refresh_cronofy_token(current_user)
    end
  end
end
