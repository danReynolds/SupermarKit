class CreateJoinTable < ActiveRecord::Migration
  def change
    create_join_table :users, :groceries, index: true
  end
end
