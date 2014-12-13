class CreateGroceryTable < ActiveRecord::Migration
  def change
    create_table :groceries do |t|
    	t.string :name
    	t.string :description
    	t.timestamps
    end
  end
end
