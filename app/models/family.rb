class Family < ApplicationRecord
  belongs_to :head, class_name: "User", foreign_key: "user_id"
  has_many :members, -> { where.not(id: user_id) }, class_name: "User", foreign_key: "family_id", dependent: :nullify
  has_many :tasks, dependent: :destroy
  has_many :appointments, dependent: :destroy

  validates :name, presence: true

  after_create :create_default_family

  def all_members
    User.where(id: members.pluck(:id) + [user_id]) # Combine family members and the head user
  end

end
