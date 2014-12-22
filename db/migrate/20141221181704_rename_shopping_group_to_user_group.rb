class RenameShoppingGroupToUserGroup < ActiveRecord::Migration
  def change
    rename_table :shopping_groups, :user_groups
    rename_table :shopping_groups_users, :user_groups_users
    rename_column :user_groups_users, :shopping_group_id, :user_group_id
  end
end
