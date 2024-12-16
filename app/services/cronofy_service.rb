require 'cronofy'

class CronofyService
  def initialize(user)
    @user = user
    refresh_token_if_needed
    @client = Cronofy::Client.new(
      access_token: @user.access_token,
      refresh_token: @user.refresh_token
    )
  end

  # Creates an appointment in Cronofy
  def create_appointment(appointment_params)
    @client.upsert_event(
      calendar_id: 'default',
      event_id: appointment_params[:event_id],
      summary: appointment_params[:summary],
      description: appointment_params[:description],
      start: appointment_params[:start].to_time.iso8601,
      end: appointment_params[:end].to_time.iso8601
    )
  end

  # Creates a task in Cronofy
  def create_task(task_params)
    @client.upsert_event(
      calendar_id: 'default',
      event_id: task_params[:event_id],
      summary: task_params[:summary],
      description: task_params[:description],
      start: task_params[:start].to_time.iso8601,
      end: task_params[:end].to_time.iso8601
    )
  end

  private

  # Refreshes access token if expired
  def refresh_token_if_needed
    if @user.token_expiration < Time.now
      Rails.logger.info "Refreshing Cronofy token for user #{@user.id}"

      client = Cronofy::Client.new(
        client_id: ENV['CRONOFY_CLIENT_ID'],
        client_secret: ENV['CRONOFY_CLIENT_SECRET']
      )

      response = client.refresh_access_token(refresh_token: @user.refresh_token)

      if @user.update(
           access_token: response.access_token,
           refresh_token: response.refresh_token,
           token_expiration: Time.now + response.expires_in.seconds
         )
        Rails.logger.info "Token refreshed successfully for user #{@user.id}"
      else
        Rails.logger.error "Failed to update refreshed tokens for user #{@user.id}"
        raise "Unable to refresh tokens. Please reconnect Cronofy."
      end
    else
      Rails.logger.info "Cronofy token is still valid for user #{@user.id}"
    end
  rescue Cronofy::AuthenticationFailureError => e
    Rails.logger.error "Cronofy token refresh failed: #{e.message}"
    raise "Failed to refresh tokens. Please reconnect Cronofy."
  end
end
