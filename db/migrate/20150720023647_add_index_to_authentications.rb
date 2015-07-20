class AddIndexToAuthentications < ActiveRecord::Migration
  def change
    add_index :authentications, :user_id
  end
end
