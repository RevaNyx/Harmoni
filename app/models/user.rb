class User < ApplicationRecord
  # Associations
  belongs_to :role
  belongs_to :family, optional: true
  has_one :owned_family, class_name: "Family", foreign_key: "user_id", dependent: :destroy
  has_many :assigned_tasks, class_name: "Task", foreign_key: "user_id", dependent: :destroy # Tasks assigned to the user
  has_many :appointments, dependent: :destroy
  has_many :tasks, through: :family, dependent: :destroy # Tasks related to the user's family

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Callbacks
  after_create :create_default_family


  # Validations
  validates :username, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, confirmation: true, length: { minimum: 6 }, if: :password_required?
  validates :role, presence: true
  
  # Attributes to store tokens
  attribute :access_token, :string
  attribute :refresh_token, :string
  attribute :account_id, :string
  attribute :token_expiration, :datetime

  # Methods

  # Returns the accessible family for the user
  def accessible_family
    owned_family || family
  end

  # Checks if the user is connected to Cronofy
  def connected?
    access_token.present? && refresh_token.present? && token_expiration && token_expiration > Time.now
  end

  private
  # Creates a default family for the user if they are a head
  def create_default_family
    return unless role.name.downcase == "head" && owned_family.nil?
  
    new_family = Family.create!(name: last_name, user_id: id)
    update!(family_id: new_family.id)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to create default family: #{e.message}")
  end
  
end
