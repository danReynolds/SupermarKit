class ChangeGroceriesItemDefaultQuantity < ActiveRecord::Migration
  def change
    change_column :groceries_items, :quantity, :integer, default: 1
  end
end
