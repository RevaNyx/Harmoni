class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @tasks = current_user.tasks
    @family = current_user.owned_family || current_user.owned_family
    @members = @family.members if @family.present? 
  end
end
