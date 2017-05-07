class AddItemsToPayments < ActiveRecord::Migration[5.0]
  def change
    create_join_table :groceries_items, :payments do |t|
      t.index :payment_id
      t.index :groceries_item_id
    end
  end
end
