class AddDefaultToAttributesOfSubscriptionss < ActiveRecord::Migration
  def up
    Subscription.find_each do |subscription|
      subscription.update_attribute(:kindle, 0)
      subscription.update_attribute(:pocket, 0)
    end
  end
end
