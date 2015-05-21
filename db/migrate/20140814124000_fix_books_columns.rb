class FixBooksColumns < ActiveRecord::Migration
  def change
    rename_column :books, :description, :recommend
    rename_column :books, :content, :summary
    add_column :books, :keys, :string, array: true, default: []
    add_column :books, :lessons, :string, array: true, default: []
    add_column :books, :quotes, :string, array: true, default: []
    add_column :books, :time, :integer
    add_column :books, :subtitle, :string
    add_column :books, :original_title, :string
  end
end
