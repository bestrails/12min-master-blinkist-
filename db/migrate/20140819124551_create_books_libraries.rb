class CreateBooksLibraries < ActiveRecord::Migration
  def change
    create_table :books_libraries, :id => false do |t|
      t.references :book
      t.references :library
    end
    add_index :books_libraries, [:book_id, :library_id]
    add_index :books_libraries, :library_id
  end
end

