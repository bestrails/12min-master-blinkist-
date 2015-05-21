class Discount < ActiveRecord::Base
  belongs_to :plan

  has_many :subscriptions

  validates :code, uniqueness: true

  def is_valid?
    (created_at + days_to_expire.days) > Date.today
  end
end
