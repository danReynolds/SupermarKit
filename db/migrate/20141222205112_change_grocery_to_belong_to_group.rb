class ChangeGroceryToBelongToGroup < ActiveRecord::Migration
  def change
    rename_column :groceries, :user_id, :user_group_id
  end
end
