class CreateRecipesItems < ActiveRecord::Migration
  def change
    add_column :items_recipes, :units, :string
    add_column :items_recipes, :quantity, :decimal, precision: 16, scale: 2
  end
end
