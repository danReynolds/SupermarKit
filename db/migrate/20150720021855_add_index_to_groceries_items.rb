class AddIndexToGroceriesItems < ActiveRecord::Migration
  def change
    add_index :groceries_items, [:item_id, :grocery_id], unique: true
    add_index :groceries_items, :grocery_id
  end
end
