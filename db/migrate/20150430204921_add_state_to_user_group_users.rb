class AddStateToUserGroupUsers < ActiveRecord::Migration
  def up
    add_column :user_groups_users, :id, :primary_key 
    add_column :user_groups_users, :state, :string, default: "invited"
    UserGroupsUsers.update_all(state: "accepted")
  end

  def down
    remove_column :user_groups_users, :state
  end
end
