class Task < ApplicationRecord
  belongs_to :user
  belongs_to :assigned_to, class_name: 'User', optional: true
  belongs_to :family

  enum priority: {:low=>0, :medium=>1, :high=>2}
  enum status: {:pending=>0, :complete=>1, :overdue=>2}

  validates :title, presence: true
  validates :description, presence: true
  validates :due_date, presence: true
  validates :priority, inclusion: { in: priorities.keys }
  validates :status, inclusion: { in: statuses.keys }
  

  scope :incomplete, -> { where(status: "pending").order(:due_date) }

end
