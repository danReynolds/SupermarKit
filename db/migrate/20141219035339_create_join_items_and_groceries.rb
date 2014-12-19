class CreateJoinItemsAndGroceries < ActiveRecord::Migration
  def change
    create_join_table :items, :groceries, index: true
  end
end
