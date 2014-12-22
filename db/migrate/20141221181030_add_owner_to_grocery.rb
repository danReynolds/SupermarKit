class AddOwnerToGrocery < ActiveRecord::Migration
  def change
    add_column :groceries, :owner_id, :integer
  end
end
