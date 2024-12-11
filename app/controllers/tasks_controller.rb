class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :set_members, only: [:new, :edit, :create]

  def index
    @tasks = @family ? @family.tasks : [] # Fetch tasks if the family exists
  end

  def show
    @family_member = @task.user # Assuming `user_id` is the assigned user
  end

  def new
    @task = @family.tasks.new
  end

  def edit
    # Task is already set by `set_task`
  end

  def create
    task_params_with_due_date = build_due_date(task_params)
  
    @task = @family.tasks.new(task_params_with_due_date.except(:hour, :minute, :ampm, :calendar_date))
  
    if @task.save
      # Call the Cronofy service to create the task
      CronofyAppointmentAndTaskService.new(current_user).create_task(cronofy_task_params(@task))  

      redirect_to tasks_path, notice: 'Task created successfully.'
    else
      flash.now[:alert] = 'Error creating task. Please check the form.'
      set_members # Ensure @members is set for re-rendering the form
      render :new, status: :unprocessable_entity
    end
  end
  

  def update
    task_params_with_due_date = build_due_date(task_params)
  
    if @task.update(task_params_with_due_date.except(:hour, :minute, :ampm, :calendar_date))
      redirect_to task_path(@task), notice: 'Task updated successfully.'
    else
      flash.now[:alert] = 'Error updating task. Please check the form.'
      set_members # Ensure @members is set for re-rendering the form
      render :edit, status: :unprocessable_entity
    end
  end
  

  def destroy
    if @task.destroy
      flash[:notice] = "Task deleted successfully."
    else
      flash[:alert] = "Failed to delete the task."
    end
    redirect_to tasks_path
  end

  private

  def build_due_date(params)
    if params[:calendar_date].present? && params[:hour].present? && params[:minute].present? && params[:ampm].present?
      date = params[:calendar_date]
      hour = params[:hour].to_i
      hour += 12 if params[:ampm] == "PM" && hour < 12
      hour = 0 if params[:ampm] == "AM" && hour == 12
      minute = params[:minute].to_i
      params[:due_date] = DateTime.parse("#{date} #{hour}:#{minute}")
    end
    params
  end

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
    redirect_to tasks_path
  end

  def set_members
    # Include the current user (head user) and any family members
    @members = @family.members.to_a
    @members << current_user unless @members.include?(current_user)
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :status, :user_id, :family_id, :due_date, :hour, :minute, :ampm, :calendar_date)
  end

  def cronofy_task_params(task)
    {
      event_id: task.id.to_s, # Use the task ID as the event identifier
      summary: task.title,
      description: task.description,
      start: task.due_date, # Assuming due_date is used as the start time
      end: task.due_date + 1.hour # Set an end time one hour after the start
    }
  end
end
