class AddIndexToGroceriesItems < ActiveRecord::Migration
  def change
    add_index :groceries_items, [:item_id, :grocery_id], unique: true
  end
end
