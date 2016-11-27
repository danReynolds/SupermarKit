class AddOwnerToUserGroups < ActiveRecord::Migration
  def change
    add_reference :user_groups, :owner
  end
end
