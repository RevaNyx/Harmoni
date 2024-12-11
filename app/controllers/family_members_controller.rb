class FamilyMembersController < ApplicationController
    before_action :set_family
    before_action :set_family_member, only: [:show, :edit, :update, :destroy]
      
    def show
      
    end
  
    def new
      @family_member = @family.members.new
    end
  
    def create
      @family_member = @family.members.new(family_member_params)
      if @family_member.save
        redirect_to family_path(@family), notice: 'Family member was successfully added.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    def edit
      # This will render the edit view for a family member
      # Allows updating the details of a specific family member
    end
  
    def update
      if @family_member.update(family_member_params)
        redirect_to family_path(@family), notice: 'Family member was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    def destroy
      @family_member.destroy
      redirect_to family_path(@family), notice: 'Family member was successfully removed.'
    end
  
    private
  
    def set_family
        Rails.logger.debug "Params for set_family: #{params.inspect}"
        @family = Family.find(params[:family_id])
      rescue ActiveRecord::RecordNotFound
        redirect_to families_path, alert: "Family not found."
      end
      
  
      def set_family_member
        Rails.logger.debug "Params for set_family_member: #{params.inspect}"
        @family_member = @family.members.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to family_path(@family), alert: "Family member not found."
      end
      
  
    def family_member_params
      params.require(:user).permit(:username, :first_name, :last_name, :role_id, :email, :birth_date, :password, :password_confirmation)
    end
  end
  