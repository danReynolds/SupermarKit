class AddPlaceIdToGroceryStore < ActiveRecord::Migration
  def change
    add_column :grocery_stores, :place_id, :string
  end
end
