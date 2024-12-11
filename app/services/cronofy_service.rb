require 'cronofy'

class CronofyService
  def initialize(user)
    @client = Cronofy::Client.new(
      access_token: user.access_token,
      refresh_token: user.refresh_token
    )
  end

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
end