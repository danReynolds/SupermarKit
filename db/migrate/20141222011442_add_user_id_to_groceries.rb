class AddUserIdToGroceries < ActiveRecord::Migration
  def up
    add_reference :groceries, :user, index: true
  end
end
