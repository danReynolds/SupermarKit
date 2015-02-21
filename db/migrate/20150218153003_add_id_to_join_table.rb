class AddIdToJoinTable < ActiveRecord::Migration
  def change
    add_column :groceries_items, :id, :primary_key
    add_column :groceries_items, :quantity, :integer, default: 1
  end
end
