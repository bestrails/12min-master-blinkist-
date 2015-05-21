class AddAttributesToPlan < ActiveRecord::Migration
  def change
    add_column :plans, :kindle_limit, :integer
    add_column :plans, :pocket_limit, :integer
  end
end
