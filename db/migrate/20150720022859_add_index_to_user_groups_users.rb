class AddIndexToUserGroupsUsers < ActiveRecord::Migration
  def change
    add_index :user_groups_users, [:user_id, :user_group_id], unique: true
    add_index :user_groups_users, :user_group_id
  end
end
