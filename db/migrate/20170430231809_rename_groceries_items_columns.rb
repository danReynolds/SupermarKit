class RenameGroceriesItemsColumns < ActiveRecord::Migration[5.0]
  def change
    rename_column :groceries_items_users, :groceries_item_id, :groceries_items_id
    rename_column :groceries_items_payments, :groceries_item_id, :groceries_items_id
  end
end
