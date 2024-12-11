class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]
  before_action :set_members, only: [:new, :edit, :create, :show]

  def index
    @appointments = current_user.appointments # Adjust based on your associations
  end

  def show
    # Uses `set_appointment` to load the appointment
  end

  def new
    @appointment = @family.appointments.new
  end

  def create
    @appointment = @family.appointments.new(appointment_params)
    @appointment.user = current_user # Assign the current user as the creator

    if @appointment.save
      redirect_to appointments_path, notice: "Appointment created successfully."
    else
      flash.now[:alert] = "Error creating appointment. Please fix the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Uses `set_appointment`
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to appointments_path, notice: "Appointment updated successfully."
    else
      flash.now[:alert] = "Error updating appointment. Please fix the errors below."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @appointment.destroy
      flash[:notice] = "Appointment deleted successfully."
    else
      flash[:alert] = "Failed to delete the appointment."
    end
    redirect_to appointments_path
  end

  private

  def set_family
    @family = current_user.family || current_user.owned_family
    unless @family
      flash[:alert] = "Please create a family first."
      redirect_to new_family_path
    end
  end

  def set_appointment
    @appointment = @family.appointments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Appointment not found."
    redirect_to appointments_path
  end

  def set_members
    @members = @family.members.to_a
    @members << current_user unless @members.include?(current_user)
  rescue NoMethodError
    @members = [current_user]
  end

  def appointment_params
    params.require(:appointment).permit(:title, :description, :start_time, :end_time, :recurrence, :user_id)
  end
end
