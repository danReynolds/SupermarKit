class AddPriceToGroceriesItems < ActiveRecord::Migration
  def change
    add_column :groceries_items, :price_cents, :integer
    GroceriesItems.all.each do |grocery_item|
      grocery_item.update_attribute(:price_cents, grocery_item.item.price_cents) if grocery_item.item
    end

    remove_column :items, :price_cents
  end
end
