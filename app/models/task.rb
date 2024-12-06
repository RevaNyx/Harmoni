class Task < ApplicationRecord
  belongs_to :user
  belongs_to :family
  enum :priority, {:low=>0, :medium=>1, :high=>2}
  enum :status, {:pending=>0, :complete=>1, :overdue=>2}

  validates :title, presence: true
  validates :due_date, presence: true

end
