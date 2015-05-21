class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.decimal :price
      t.integer :books_limit
      t.integer :active_days

      t.timestamps
    end
  end
end
