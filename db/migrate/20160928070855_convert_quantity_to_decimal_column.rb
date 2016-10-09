class ConvertQuantityToDecimalColumn < ActiveRecord::Migration
  def change
    change_column :groceries_items, :quantity, :decimal, precision: 16, scale: 2
  end
end
