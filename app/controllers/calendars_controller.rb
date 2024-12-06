class CalendarsController < ApplicationController
    before_action :authenticate_user!
  
    # List all connected calendars
    def index
      if current_user.cronofy_connected?
        client = cronofy_client(current_user)
        @calendars = client.list_calendars
      else
        @calendars = []
        flash[:alert] = "No calendars connected. Please connect a calendar first."
        redirect_to auth_cronofy_path
      end
    end
  
    # Show available time slots for a specific calendar
    def show
      @cronofy = cronofy_client(current_user)
      @calendar_ids = [params[:id]]
  
      @availability_request = {
        participants: [
          {
            members: [
              {
                sub: current_user.account_id,
                calendar_ids: @calendar_ids
              }
            ]
          }
        ],
        required_duration: { minutes: 30 },
        available_periods: [
          {
            start: (Time.now + 1.hour).utc.iso8601,
            end: (Time.now + 2.days).utc.iso8601
          }
        ]
      }
  
      @available_slots = @cronofy.availability(@availability_request)
    end
  end
  