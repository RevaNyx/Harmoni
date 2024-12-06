class FamiliesController < ApplicationController
  before_action :authenticate_user!

  

  def show
    @family = Family.find(params[:id])
    @new_member = User.new
  end

  def new
    @family = current_user.owned_family || current_user.family
    if @family.nil?
      redirect_to dashboard_path, alert: "No family found. Please create a family first."
    else
      @new_member = User.new
    end
  end


  def create_member
    @family = Family.find(params[:id]) # Find the family by ID
    @new_member = @family.members.build(user_params) # Build the new member tied to this family
  
    if @new_member.save
      redirect_to dashboard_path, notice: "Family member added successfully." # Redirect to dashboard
    else
      flash.now[:alert] = "Error adding member. Please fix the errors below."
      render :show # Re-render the show page with the form
    end
  end
  

  def create
    @family = current_user.build_owned_family(family_params)

    if @family.save
      redirect_to @family, notice: "Family successfully created."
    else
      render :new, alert: "Unable to create family."
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :email, :role_id, :password, :password_confirmation)
  end
  
  


  def family_params
    params.require(:family).permit(:name)
  end
end
