class CreateDiscounts < ActiveRecord::Migration
  def change
    create_table :discounts do |t|
      t.references :subscription, index: true
      t.float :percentage
      t.date :expires_on
      t.string :code

      t.timestamps
    end
  end
end
