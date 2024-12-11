class FamiliesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_head_user, only: [:remove_member]
  before_action :set_family, only: [:show, :edit, :update, :destroy]
  before_action :set_family_member, only: [:edit, :update, :destroy]
  before_action :ensure_head_user, only: [:edit, :update, :destroy]


  def index
    @family = current_user.family # Assuming you have an association `has_one :family` in the User model
    @members = @family.members if @family.present? # Assuming Family has_many :members
  end

  def show
    # This action uses @family set by the `set_family` method for the view
  end

  def new
    @family = current_user.owned_family || current_user.family
    if @family.nil?
      redirect_to new_family_path, alert: "No family found. Please create a family."
    else
      @new_member = User.new
    end
  end

  def edit
    # @family is already set by `set_family`
  end

  def update
    if @family.update(family_params)
      redirect_to @family, notice: "Family successfully updated."
    else
      flash.now[:alert] = "Unable to update family. Please fix the errors below."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @family.destroy
    redirect_to families_path, notice: "Family successfully deleted."
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

  def all_members
    User.where(family_id: id) # Includes all users with this family_id, including the head
  end

  private

  def set_family
    @family = Family.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Family not found."
  end

  def set_family_member
    @family_member = @family.members.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to family_path(@family), alert: "Family member not found."
  end

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

  def create_default_family
    return unless role.name.downcase == "head" && owned_family.nil?

    begin
      new_family = Family.create!(name: "#{last_name}", user_id: id)
      update!(family_id: new_family.id)
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to create default family: #{e.message}")
    end
  end
end
