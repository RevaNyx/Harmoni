class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  
  def index
    @family = current_user.family || current_user.owned_family
    @tasks = @family&.tasks || []
    @members = @family&.all_members || []
    @appointments = @family&.appointments || [] # Fetch appointments associated with the family
  end

  
end
