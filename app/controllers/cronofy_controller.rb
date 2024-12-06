class CronofyController < ApplicationController
end
class CronofyController < ApplicationController
    def connect
      client = cronofy_client
      @authorization_url = client.user_auth_link(auth_callback_url)
      redirect_to @authorization_url, allow_other_host: true
    end

    def authorize
        client = Cronofy::Client.new(
          client_id: ENV['CRONOFY_CLIENT_ID'],
          client_secret: ENV['CRONOFY_CLIENT_SECRET']
        )
        redirect_to client.authorization_url(
          redirect_uri: ENV['CRONOFY_REDIRECT_URI'],
          scope: 'read_write'
        )
    end
    
  
    def callback
        client = Cronofy::Client.new(
          client_id: ENV['CRONOFY_CLIENT_ID'],
          client_secret: ENV['CRONOFY_CLIENT_SECRET']
        )
    
        if params[:code].present?
          # Exchange the authorization code for access tokens
          token = client.get_token_from_code(params[:code])
    
          # Save tokens securely (adjust for your app's user model)
          current_user.update!(
            cronofy_access_token: token.access_token,
            cronofy_refresh_token: token.refresh_token
          )
    
          redirect_to dashboard_path, notice: 'Cronofy integration successful!'
        else
          redirect_to root_path, alert: 'Authorization failed. Please try again.'
        end
      end
  
    private
  
    def auth_callback_url
      "#{request.base_url}/auth/cronofy/callback"
    end
  end
  