class AddFinishedToGrocery < ActiveRecord::Migration
  def change
    add_column :groceries, :finished, :boolean, default: false
  end
end
