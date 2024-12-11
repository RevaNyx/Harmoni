class Users::RegistrationsController < Devise::RegistrationsController
    protected
  
    # Restrict sign-up for users under 18 for the "head" role
    def sign_up_params
      Rails.logger.debug("Sign-up Params: #{params.inspect}") # Log all params
      permitted_params = params.require(:user).permit(:username, :first_name, :last_name, :email, :password, :password_confirmation, :birth_date, :role_id)
      Rails.logger.debug("Permitted Params: #{permitted_params.inspect}") # Log permitted params
      permitted_params
    end
  
    def account_update_params
      params.require(:user).permit(:username, :first_name, :last_name, :email, :password, :password_confirmation, :current_password, :birth_date, :role_id)
    end
  
    def after_sign_up_path_for(resource)
      if resource.role == 'head' && resource.age < 18
        flash[:alert] = "You must be at least 18 years old to sign up as Head of Household."
        sign_out(resource)
        new_user_registration_path
      else
        super
      end
    end
  end
  