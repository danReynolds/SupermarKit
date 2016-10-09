class AddDefaultToItemsRecipesQuantity < ActiveRecord::Migration
  def change
    change_column :items_recipes, :quantity, :decimal, default: 1, precision: 16, scale: 2
  end
end
