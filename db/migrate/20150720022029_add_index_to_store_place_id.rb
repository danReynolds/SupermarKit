class AddIndexToStorePlaceId < ActiveRecord::Migration
  def change
    add_index :grocery_stores, :place_id
  end
end
