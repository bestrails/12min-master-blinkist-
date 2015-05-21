class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :plan
  belongs_to :discount

  validates :expires_on, presence: true

  state_machine :state, :initial => :actived do
    after_transition :paused => :actived do |subscription, transition|
      subscription.update_attribute(:expires_on, (Date.today + subscription.plan.active_days.days))
    end

    event :pause do
      transition :actived => :paused
    end

    event :active do
      transition :paused => :actived
    end
  end

  scope :expires, -> { where('expires_on < ?', Date.today) }

  def upgrade_by_referral
    update_attribute(:expires_on, (expires_on + 7.days))
  end

  def discounting(discount)
    update_attribute(:discount, discount)
  end
end
