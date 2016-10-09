class AddIdToRecipesItems < ActiveRecord::Migration
  def change
    add_column :items_recipes, :id, :primary_key
  end
end
