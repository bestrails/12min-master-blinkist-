class AddDefaultValueToDiscountCodes < ActiveRecord::Migration
  def change
    change_column :users, :discount_codes, :string, array:true, :default => []
  end
end
