class AddDefaultToUserGroup < ActiveRecord::Migration
  def up
    add_column :user_groups, :user_group_default_id, :integer
  end

  def down
    remove_column :user_groups, :user_group_default_id
  end
end
