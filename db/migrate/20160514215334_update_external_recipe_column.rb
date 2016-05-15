class UpdateExternalRecipeColumn < ActiveRecord::Migration
  def change
    remove_column :recipes, :recipe_id
    add_column :recipes, :external_id, :string
  end
end
