class UsersController < ApplicationController
    before_action :authenticate_user!

        # Returns the user's Cronofy access token
    def cronofy_access_token
        self[:cronofy_access_token]
    end

    # Returns the user's Cronofy refresh token
    def cronofy_refresh_token
        self[:cronofy_refresh_token]
    end

    def index
        @users = User.all
        @cronofy = cronofy_client
        @authorization_url = @cronofy.user_auth_link('http://localhost:3000/oauth2/callback')
    end

    def connect
        @cronofy = cronofy_client()
        code = [params[:code]]
        response = @cronofy.get_token_from_code(code, 'http://localhost:3000/oauth2/callback')

        if User.where(account_id: response.account_id).exists?
            user = User.find_by(account_id: response.account_id)
            user.update(
                access_token: response.access_token,
                refresh_token: response.refresh_token
            )
            user.save
        else
            user = User.create(
                account_id: response.account_id,
                access_token: response.access_token,
                refresh_token: response.refresh_token
            )
        end

        redirect_to root_path
    end
end
