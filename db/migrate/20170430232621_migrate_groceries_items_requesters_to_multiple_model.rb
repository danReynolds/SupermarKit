class MigrateGroceriesItemsRequestersToMultipleModel < ActiveRecord::Migration[5.0]
  def change
    GroceriesItems.all.each do |groceries_item|
      if requester_id = groceries_item.requester_id
        groceries_item.requesters << User.find(requester_id)
      end
    end

    remove_column :groceries_items, :requester_id
  end
end
