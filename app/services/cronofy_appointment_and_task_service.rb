require 'cronofy'
class CronofyAppointmentAndTaskService
    attr_reader :cronofy
    
    def initialize(user)
        @cronofy = CronofyService.new(user)
    end
    
    def create_appointment(appointment_params)
        cronofy.create_appointment(appointment_params)
    end
    
    def create_task(task_params)
        cronofy.create_task(task_params)
    end
end