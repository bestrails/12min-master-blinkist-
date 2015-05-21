class AddStateToLibrarians < ActiveRecord::Migration
  def change
    add_column :librarians, :state, :string
  end
end
