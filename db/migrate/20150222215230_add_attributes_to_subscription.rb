class AddAttributesToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :kindle, :integer
    add_column :subscriptions, :pocket, :integer
  end
end
