class AppointmentsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_family
    before_action :set_appointment, only: [:show, :update]
  
    def show
      # @appointment is already set by set_appointment
      # If no appointment exists, it defaults to a new one in set_appointment
    end

    def edit
        redirect_to appointment_path(id: nil)
    end

    def new
        redirect_to appointment_path(id: nil)
      end
      
  
    def create
      @appointment = @family.appointments.new(appointment_params)
      @appointment.user = current_user # Assign the current user as the creator
  
      if @appointment.save
        redirect_to dashboard_path, notice: "Appointment created successfully."
      else
        flash.now[:alert] = "Error creating appointment. Please fix the errors below."
        render :show, status: :unprocessable_entity
      end
    end
  
    def update
      if @appointment.update(appointment_params)
        redirect_to dashboard_path, notice: "Appointment updated successfully."
      else
        flash.now[:alert] = "Error updating appointment. Please fix the errors below."
        render :show, status: :unprocessable_entity
      end
    end

    def destroy
        @appointment = @family.appointments.find(params[:id])
      
        if @appointment.destroy
          flash[:notice] = "Appointment deleted successfully."
        else
          flash[:alert] = "Failed to delete the appointment."
        end
      
        redirect_to dashboard_path # Redirect to the dashboard after deleting
      end
      
      
      
      
  
    private
  
    def set_family
      @family = current_user.family || current_user.owned_family
    end
  
    def set_appointment
      @appointment = @family.appointments.find_by(id: params[:id]) || @family.appointments.new
    end
  
    def appointment_params
      params.require(:appointment).permit(:title, :description, :start_time, :end_time, :recurrence, :user_id)
    end
  end
  