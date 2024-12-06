class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :first_name, :last_name, :role_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :first_name, :last_name, :role_id])
  end

  private

  def cronofy_client(user = nil)
    Cronofy::Client.new(
      client_id: Rails.application.credentials[:cronofy][:client_id],
      client_secret: Rails.application.credentials[:cronofy][:client_secret],
      data_center: Rails.application.credentials[:cronofy][:data_center],
      access_token: user&.access_token,
      refresh_token: user&.refresh_token
    )
  end

end
