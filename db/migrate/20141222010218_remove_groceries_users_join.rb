class RemoveGroceriesUsersJoin < ActiveRecord::Migration
  def change
    drop_table :groceries_users
  end
end
