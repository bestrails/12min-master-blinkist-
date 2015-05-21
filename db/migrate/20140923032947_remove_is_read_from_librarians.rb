class RemoveIsReadFromLibrarians < ActiveRecord::Migration
  def change
    remove_column :librarians, :is_read
  end
end
