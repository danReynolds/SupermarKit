class CreateShoppingGroups < ActiveRecord::Migration
  def change
    create_table :shopping_groups do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
  end
  create_join_table :shopping_groups, :users, index: true
end
