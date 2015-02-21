class AddIdToJoinTable < ActiveRecord::Migration
  def change
    add_column :groceries_items, :id, :primary_key
  end
end
