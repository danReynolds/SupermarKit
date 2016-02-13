class AddAdderToGroceryItem < ActiveRecord::Migration
  def self.up
    add_reference :groceries_items, :requester
  end

  def self.down
    remove_reference :groceries_items, :requester
  end
end
