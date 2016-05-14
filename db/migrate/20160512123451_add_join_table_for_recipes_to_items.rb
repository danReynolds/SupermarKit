class AddJoinTableForRecipesToItems < ActiveRecord::Migration
  def change
    create_join_table :items, :recipes, index: true
    remove_column :groceries_items, :recipe_id
  end
end
