class AddReferenceToGrocery < ActiveRecord::Migration
  def change
    add_reference :groceries, :grocery_store
  end
end
