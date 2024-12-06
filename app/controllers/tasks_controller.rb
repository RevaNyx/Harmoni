class TasksController < ApplicationController
    before_action :authenticate_user!


    def show
        @task = current_user.tasks.find(params[:id])
    end

    def edit
        @task = current_user.tasks.find(params[:id])
    end

    def update
        @task = current_user.tasks.find(params[:id])
        if @task.update(task_params)
            redirect_to dashboard_path, notice: "Task updated successfully."
        else
            render :edit, status: :unprocessable_entity
        end
    end
    
  
    def new
      @task = Task.new
    end
  
    def create
      @task = current_user.tasks.build(task_params)
      if @task.save
        redirect_to dashboard_path, notice: "Task created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
        @task = current_user.tasks.find(params[:id])
        @task.destroy
        redirect_to dashboard_path, notice: "Task deleted successfully."
    end
  
    private

    def set_task
        @task = current_user.tasks.find(params[:id])
      end
  
    def task_params
      params.require(:task).permit(:title, :description, :due_date, :priority, :status)
    end
  end
  