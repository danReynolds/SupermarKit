class AddMultipleRequestersToGroceriesItems < ActiveRecord::Migration[5.0]
  def change
    create_join_table :groceries_items, :users do |t|
      t.index :user_id
      t.index :groceries_item_id
    end

    
  end
end
