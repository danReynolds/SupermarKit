class CreateGroceryStoreTable < ActiveRecord::Migration
  def change
    create_table :grocery_stores do |t|
      t.string :name
      t.decimal :lat, precision: 10, scale: 6, index: true
      t.decimal :lng, precision: 10, scale: 6, index: true
    end
  end
end
