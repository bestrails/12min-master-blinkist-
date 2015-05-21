class ChangeForDiscount < ActiveRecord::Migration
  def change
    remove_column :discounts, :subscription_id
    add_reference :discounts, :plan, index: true
    add_reference :subscriptions, :discount, index: true
  end
end
