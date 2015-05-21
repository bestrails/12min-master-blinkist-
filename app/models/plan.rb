class Plan < ActiveRecord::Base
  has_many :subscriptions
  has_many :discounts

  validates :name, presence: true, uniqueness: true
  validates :active_days, presence: true, numericality: { greater_than: 0 }

  def is_trial?
    name == 'Trial'
  end
end
