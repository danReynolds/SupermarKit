class CreateJoinTableRecipeToGroceries < ActiveRecord::Migration
  def change
    create_join_table :groceries, :recipes, index: true
  end
end
