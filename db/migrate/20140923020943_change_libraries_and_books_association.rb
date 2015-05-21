class ChangeLibrariesAndBooksAssociation < ActiveRecord::Migration
  def change
    drop_table :books_libraries 
  end
end
