class CreateRecipesTable < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :url
      t.timestamps
    end

    add_reference :groceries_items, :recipe, index: true
  end
end
