class AddIndexToDefaultGroup < ActiveRecord::Migration
  def change
    rename_column :user_groups, :user_group_default_id, :user_default_id
    add_index :user_groups, :user_default_id
  end
end
