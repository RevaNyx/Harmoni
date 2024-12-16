class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    Rails.logger.info("Dashboard Accessed by User ID: #{current_user.id}")
    Rails.logger.info("Current User Tokens: Access - #{current_user.access_token}, Refresh - #{current_user.refresh_token}, Expiration - #{current_user.token_expiration}")

    @family = fetch_family
    @tasks = fetch_tasks
    @members = fetch_members
    @appointments = fetch_appointments
    @calendars = fetch_calendars
  end

  private

  # Fetch the family associated with the user
  def fetch_family
    family = current_user.family || current_user.owned_family
    if family
      Rails.logger.info("Family fetched for User ID #{current_user.id}: #{family.inspect}")
    else
      Rails.logger.warn("No family found for User ID #{current_user.id}")
    end
    family
  end

  # Fetch tasks for the family
  def fetch_tasks
    if @family
      tasks = @family.tasks
      Rails.logger.info("Tasks fetched for Family ID #{@family.id}: #{tasks.count} tasks")
      tasks
    else
      Rails.logger.warn("No tasks fetched because family is nil for User ID #{current_user.id}")
      []
    end
  end

  # Fetch family members
  def fetch_members
    if @family
      members = @family.all_members
      Rails.logger.info("Members fetched for Family ID #{@family.id}: #{members.count} members")
      members
    else
      Rails.logger.warn("No members fetched because family is nil for User ID #{current_user.id}")
      []
    end
  end

  # Fetch appointments for the family
  def fetch_appointments
    if @family
      appointments = @family.appointments
      Rails.logger.info("Appointments fetched for Family ID #{@family.id}: #{appointments.count} appointments")
      appointments
    else
      Rails.logger.warn("No appointments fetched because family is nil for User ID #{current_user.id}")
      []
    end
  end

  # Fetch connected calendars
  def fetch_calendars
    return [] unless current_user.connected?

    Rails.logger.info("Fetching calendars for User ID: #{current_user.id}")
    begin
      refresh_token_if_needed(current_user)
      client = cronofy_client(current_user)
      calendars = client.list_calendars
      Rails.logger.info("Calendars fetched: #{calendars.inspect}")
      calendars
    rescue Cronofy::AuthenticationFailureError => e
      Rails.logger.error("Cronofy Authentication Error: #{e.message}")
      flash[:alert] = "Your Cronofy connection has expired. Please reconnect."
      []
    rescue StandardError => e
      Rails.logger.error("Cronofy Error: #{e.message}")
      flash[:alert] = "Unable to fetch calendars. Please try again later."
      []
    end
  end

  # Initializes the Cronofy client
  def cronofy_client(user)
    client = Cronofy::Client.new(
      client_id: Rails.application.credentials.dig(:cronofy, :client_id),
      client_secret: Rails.application.credentials.dig(:cronofy, :client_secret),
      data_center: Rails.application.credentials.dig(:cronofy, :data_center) || 'us',
      access_token: user.access_token,
      refresh_token: user.refresh_token
    )
    Rails.logger.info("Cronofy client initialized for User ID: #{user.id}")
    client
  end

  # Refreshes the user's Cronofy token if expired
  def refresh_token_if_needed(user)
    return if user.token_expiration > Time.now

    Rails.logger.info("Refreshing token for User ID: #{user.id}")
    client = Cronofy::Client.new(
      client_id: Rails.application.credentials.dig(:cronofy, :client_id),
      client_secret: Rails.application.credentials.dig(:cronofy, :client_secret)
    )

    response = client.refresh_access_token(refresh_token: user.refresh_token)
    if user.update!(
         access_token: response.access_token,
         refresh_token: response.refresh_token,
         token_expiration: Time.now + response.expires_in.seconds
       )
      Rails.logger.info("Token refreshed successfully for User ID: #{user.id}")
    else
      Rails.logger.error("Failed to refresh token for User ID: #{user.id}")
    end
  rescue Cronofy::AuthenticationFailureError => e
    Rails.logger.error("Failed to refresh Cronofy token for User ID #{user.id}: #{e.message}")
    raise
  end
end
