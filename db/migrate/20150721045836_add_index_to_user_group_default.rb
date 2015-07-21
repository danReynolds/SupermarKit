class AddIndexToUserGroupDefault < ActiveRecord::Migration
  def change
    add_index :users, :user_group_default_id
  end
end
