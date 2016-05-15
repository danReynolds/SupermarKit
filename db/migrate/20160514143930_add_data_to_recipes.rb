class AddDataToRecipes < ActiveRecord::Migration
  def up
    add_column :recipes, :recipe_id, :integer
    add_column :recipes, :image_url, :string
    add_column :recipes, :rating, :integer
    add_column :recipes, :timeInSeconds, :integer
  end

  def down
    remove_column :recipes, :recipe_id
    remove_column :recipes, :image_url
    remove_column :recipes, :rating
  end
end
