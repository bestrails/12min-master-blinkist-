class CreateLibrarians < ActiveRecord::Migration
  def change
    create_table :librarians do |t|
      t.references :library, index: true
      t.references :book, index: true
      t.boolean :is_read, default: false

      t.timestamps
    end
  end
end
