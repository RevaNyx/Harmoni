class User < ApplicationRecord
  # Associations
  belongs_to :role
  belongs_to :family, optional: true
  has_one :owned_family, class_name: "Family", foreign_key: "user_id", dependent: :destroy
  has_many :assigned_tasks, class_name: "Task", foreign_key: "user_id", dependent: :destroy # Tasks assigned to the user
  has_many :appointments, dependent: :destroy

  after_create :create_family_if_head

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Callbacks
  after_create :create_family_if_head

  validates :username, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, confirmation: true, length: { minimum: 6 }, if: :password_required?

  # Methods
  def accessible_family
    owned_family || family
  end

  def cronofy_connected?
    access_token.present? && refresh_token.present?
  end


  private

  # Automatically create a family for the user if they are the 'Head'
  def create_family_if_head
    if role.name.downcase == "head" && owned_family.nil?
      create_owned_family(name: "#{last_name}")
    end
  end
end
