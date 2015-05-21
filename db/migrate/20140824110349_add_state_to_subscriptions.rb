class AddStateToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :state, :string
  end
end
