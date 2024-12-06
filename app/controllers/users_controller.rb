class UsersController < ApplicationController
    before_action :authenticate_user!
  
    def connect
      @cronofy = cronofy_client
      @authorization_url = @cronofy.user_auth_link(auth_callback_url)
      redirect_to @authorization_url, allow_other_host: true
    end
  
    def callback
      @cronofy = cronofy_client
      response = @cronofy.get_token_from_code(params[:code], auth_callback_url)
  
      current_user.update(
        access_token: response.access_token,
        refresh_token: response.refresh_token,
        account_id: response.account_id
      )
  
      redirect_to dashboard_path, notice: 'Calendar connected successfully!'
    end
  
    private
  
    def auth_callback_url
      "#{request.base_url}/auth/cronofy/callback"
    end
  
    def cronofy_client
      Cronofy::Client.new(
        client_id: Rails.application.credentials[:cronofy][:client_id],
        client_secret: Rails.application.credentials[:cronofy][:client_secret],
        data_center: Rails.application.credentials[:cronofy][:data_center]
      )
    end
  end
  