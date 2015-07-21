class UpdateUserGroupDefaults < ActiveRecord::Migration
  def change
    remove_column :user_groups, :user_default_id
    add_column :users, :user_group_default_id, :integer
  end
end
