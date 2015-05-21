class AddDiscountCodesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :discount_codes, :string, array: true
  end
end
