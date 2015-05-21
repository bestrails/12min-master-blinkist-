class AddKindleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :kindle, :string
  end
end
