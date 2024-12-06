class Family < ApplicationRecord
  belongs_to :head, class_name: "User", foreign_key: "user_id"
  has_many :members, class_name: "User", foreign_key: "family_id", dependent: :nullify

  validates :name, presence: true
end
