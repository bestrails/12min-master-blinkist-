class ChangeStringArrayFormatInBooks < ActiveRecord::Migration
  def change
    change_column :books, :keys, :text, array: true, default: []
    change_column :books, :lessons, :text, array: true, default: []
    change_column :books, :quotes, :text, array: true, default: []
  end
end
