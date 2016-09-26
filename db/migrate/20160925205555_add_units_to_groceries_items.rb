class AddUnitsToGroceriesItems < ActiveRecord::Migration
  def up
    add_column :groceries_items, :units, :string
  end

  def down
    remove_column :groceries_items, :units
  end
end
