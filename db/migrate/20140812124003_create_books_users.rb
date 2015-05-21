class CreateBooksUsers < ActiveRecord::Migration
  def change
    create_table :books_users, :id => false do |t|
      t.references :book
      t.references :user
    end
    add_index :books_users, [:book_id, :user_id]
    add_index :books_users, :user_id
  end
end
