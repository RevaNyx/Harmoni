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
  validates :role_id, presence: true
  validate :head_role_age_restriction, if: -> { role == 'head' }

  # Attributes to store tokens
  attribute :access_token, :string
  attribute :refresh_token, :string
  attribute :account_id, :string
  attribute :token_expiration, :datetime

  # Methods

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.access_token = auth.credentials.token
      user.refresh_token = auth.credentials.refresh_token
      user.account_id = auth.uid
      user.save!
    end
  end

  def birth_date=(value)
    if value.is_a?(Hash)
      self[:birth_date] = Date.new(value['(1i)'].to_i, value['(2i)'].to_i, value['(3i)'].to_i) rescue nil
    else
      super
    end
  end

  

  def age
    return unless birth_date

    today = Date.today
    age = today.year - birth_date.year
    age -= 1 if birth_date > today - age.years # Adjust for birthday not passed yet this year
    age
  end

  # Returns the accessible family for the user
  def accessible_family
    owned_family || family
  end

  # Checks if the user is connected to Cronofy
  def connected?
    access_token.present? && refresh_token.present? && token_expiration && token_expiration > Time.now
  end

  private

  def head_role_age_restriction
    if age.present? && age < 18
      errors.add(:birth_date, 'You must be at least 18 years old to be the Head of Household.')
    end
  end

  # Creates a default family for the user if they are a head
  def create_default_family
    Rails.logger.debug("Creating default family for user: #{inspect}")
    
    return unless role.name.downcase == "head" && owned_family.nil?
  
    new_family = Family.create!(name: last_name, user_id: id)
    Rails.logger.debug("New family created: #{new_family.inspect}")
    
    update!(family_id: new_family.id)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to create default family: #{e.message}")
  end
  
  
end
