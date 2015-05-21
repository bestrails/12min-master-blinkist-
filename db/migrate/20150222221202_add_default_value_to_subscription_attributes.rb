class AddDefaultValueToSubscriptionAttributes < ActiveRecord::Migration
  def change
    change_column :subscriptions, :kindle, :integer, :default => 0
    change_column :subscriptions, :pocket, :integer, :default => 0
  end
end
