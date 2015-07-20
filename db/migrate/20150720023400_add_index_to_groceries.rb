class AddIndexToGroceries < ActiveRecord::Migration
  def change
    add_index :groceries, :grocery_store_id
  end
end
