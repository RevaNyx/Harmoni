class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  
  def index
    @family = current_user.family || current_user.owned_family
    @tasks = @family&.tasks || []
    @members = @family&.all_members || []
    @appointments = @family&.appointments || [] # Fetch appointments associated with the family

    if current_user.cronofy_connected?
      client = cronofy_client(current_user)
      @calendars = client.list_calendars
    else
      @calendars = []
    end
  end

  
end
