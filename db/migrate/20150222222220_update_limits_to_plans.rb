class UpdateLimitsToPlans < ActiveRecord::Migration
  def up
    Plan.find_each do |plan|
      plan.update_attribute(:kindle_limit, 5)
      plan.update_attribute(:pocket_limit, 5)
    end
  end
end
