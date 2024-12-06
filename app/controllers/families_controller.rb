class FamiliesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_head_user, only: [:remove_member]

  

  def show
    @family = Family.find(params[:id])
    @new_member = User.new
  end

  def new
    @family = current_user.owned_family || current_user.family
    if @family.nil?
      redirect_to new_family_path, alert: "No family found. Please create a family."
    else
      @new_member = User.new
    end
  end
  


  def create_member
    @family = Family.find(params[:id]) # Find the family by ID
    @new_member = @family.members.build(user_params) # Build the new member tied to this family
  
    if @new_member.save
      redirect_to dashboard_path, notice: "Family member added successfully."
    else
      Rails.logger.debug "Validation Errors: #{@new_member.errors.full_messages}"
      flash.now[:alert] = "Error adding member. Please fix the errors below."
      render :show, status: :unprocessable_entity
    end
  end
  
  

  def create
    @family = current_user.build_owned_family(family_params)
    
    if @family.save
      current_user.update(family: @family) # Associate user with the family
      redirect_to @family, notice: "Family successfully created."
    else
      flash.now[:alert] = "Unable to create family."
      render :new
    end
  end

  def remove_member
    @family = Family.find(params[:id])
    @member = @family.members.find(params[:member_id])

    if @member == @family.head
      flash[:alert] = "You cannot remove yourself as the head of the family."
    elsif @member.update(family_id: nil)
      flash[:notice] = "#{@member.first_name} has been removed from the family."
    else
      flash[:alert] = "Unable to remove family member."
    end

    redirect_to dashboard_path
  end

  

  private

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :email, :role_id, :password, :password_confirmation)
  end
  
  


  def family_params
    params.require(:family).permit(:name)
  end

  def ensure_head_user
    @family = Family.find(params[:id])
    unless current_user == @family.head
      flash[:alert] = "You are not authorized to remove family members."
      redirect_to dashboard_path
    end
  end

end
