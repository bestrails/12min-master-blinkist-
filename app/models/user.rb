class User < ActiveRecord::Base
  include Referrable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  before_create :build_default_library, :build_default_subscription

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  belongs_to :referrer, :class_name => "User", :foreign_key => "referrer_id"
  has_many :referrals, :class_name => "User", :foreign_key => "referrer_id"

  has_one :library
  has_one :subscription

  accepts_nested_attributes_for :library

  validates :referral_code, uniqueness: true
  validates :kindle, format: /\A([^@\s]+)@kindle.com\Z/i, allow_blank: true
  validates :role, inclusion: { in: %w(superuser user) }

  def referral(referer)
    subscription.upgrade_by_referral && referrals.push(referer)
  end

  def discount(code)
    discount_codes_will_change!
    update_attributes discount_codes: discount_codes.push(code)
  end

  def superuser?
    role == 'superuser'
  end

  def add_kindle
    subscription.update_attribute(:kindle, (subscription.kindle + 1))
  end

  def add_pocket
    subscription.update_attribute(:pocket, (subscription.pocket + 1))
  end

  def reset_kindle
    subscription.update_attribute(:kindle, 0)
  end

  def reset_pocket
    subscription.update_attribute(:pocket, 0)
  end

  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          email: email ? email : "change@me-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0,20]
        )
        user.save!
        track_signed_up(user)
      else
        track_logged_in(user)
      end
    else
      track_logged_in(user)
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  private
  def build_default_library
    build_library
    true
  end

  def build_default_subscription
    trial_plan

    build_subscription({ 
      plan: @trial_plan, 
      expires_on: @trial_plan.active_days.days.from_now 
    })
    
    true
  end

  def trial_plan
    @trial_plan ||= Plan.find_by_name('Trial')
  end

  def self.track_signed_up(user)
    return unless ENV['SEGMENT_IO_KEY']
    Analytics.track(anonymous_id: user.email, event: 'Signed Up')
  end

  def self.track_logged_in(user)
    return unless ENV['SEGMENT_IO_KEY']
    Analytics.track(user_id: user.id, event: 'Logged in')
  end
end
