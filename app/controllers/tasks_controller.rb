class TasksController < ApplicationController
    before_action :authenticate_user!
    Rails.logger.debug "Current Family: #{@family.inspect}"



    def show
        @task = current_user.tasks.find(params[:id])
    end

    def edit
        @task = current_user.tasks.find(params[:id])
    end

    def update
        @task = Task.find(params[:id])
        if @task.update(task_params)
          redirect_to dashboard_path, notice: "Task updated successfully."
        else
          flash.now[:alert] = "Failed to update task."
          render :edit
        end
    end
    
    
  
    def new
        @family = current_user.family || current_user.owned_family
        @task = @family.tasks.new
        @members = @family.members # List of family members to assign the task
    end
    
  
    def create
        @family = current_user.family || current_user.owned_family
        @task = @family.tasks.new(task_params)
        @members = @family.members # Ensure @members is set for rendering the form
      
        if @task.save
            redirect_to dashboard_path, notice: "Task created successfully."
        else
            flash.now[:alert] = "Failed to create task. Please fix the errors below."
            render :new
        end
    end
      
    

    def destroy
        @task = Task.find(params[:id])
      
        unless @task.family == current_user.family || current_user.owned_family == @task.family
          flash[:alert] = "You are not authorized to delete this task."
          redirect_to dashboard_path and return
        end
      
        if @task.destroy
          flash[:notice] = "Task deleted successfully."
        else
          flash[:alert] = "Failed to delete the task."
        end
      
        redirect_to dashboard_path
    end
      
  
    private

    def set_task
        @task = current_user.tasks.find(params[:id])
      end
  
    def task_params
      params.require(:task).permit(:title, :description, :due_date, :priority, :status, :user_id)
    end
  end
  