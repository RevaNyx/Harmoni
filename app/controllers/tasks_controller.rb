class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = @family ? @family.tasks : [] # Fetch tasks if the family exists
  end

  def show
    # @task is already set by `set_task`
  end

  def edit
    @task = @family.tasks.find(params[:id])
    @members = @family.members # Ensure @members is set for the dropdown
  end

  def update
    Rails.logger.debug "Params: #{params.inspect}" # Debugging
    if @task.update(task_params)
      redirect_to tasks_path, notice: "Task updated successfully."
    else
      flash.now[:alert] = "Failed to update task."
      render :edit
    end
  end

  def new
    @task = @family.tasks.new
    @members = @family.members # List of family members to assign the task
  end

  def create
    @task = @family.tasks.new(task_params)
    @members = @family.members # Ensure @members is set for rendering the form

    if @task.save
      redirect_to tasks_path, notice: "Task created successfully."
    else
      flash.now[:alert] = "Failed to create task. Please fix the errors below."
      render :new
    end
  end

  def destroy
    @task = @family.tasks.find(params[:id])
    if @task.destroy
      flash[:notice] = "Task deleted successfully."
    else
      flash[:alert] = "Failed to delete the task."
    end
    redirect_to tasks_path
  end
  
  
  
  private

  def set_family
    @family = current_user.family || current_user.owned_family
    unless @family
      flash[:alert] = "Please create a family first."
      redirect_to new_family_path
    end
  end

  def set_task
    @task = @family.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Task not found."
    redirect_to dashboard_path
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :priority, :status, :user_id)
  end
end
