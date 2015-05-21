class AddColumnsToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :days_to_expire, :integer
  end
end
