class AddColumnsToBooks < ActiveRecord::Migration
  def change
    add_column :books, :author, :string
    add_column :books, :title, :string
    add_column :books, :description, :text
    add_column :books, :content, :text
  end
end
