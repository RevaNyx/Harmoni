class Appointment < ApplicationRecord
  belongs_to :family
  belongs_to :user, optional: true # User is optional for general family appointments

  enum recurrence: { no_recurrence: 0, daily: 1, weekly: 2, monthly: 3, yearly: 4 }


  validates :title, :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end
end
