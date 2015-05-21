class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.date :expires_on
      t.references :user, index: true
      t.references :plan, index: true

      t.timestamps
    end
  end
end
