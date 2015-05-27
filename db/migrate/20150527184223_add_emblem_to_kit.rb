class AddEmblemToKit < ActiveRecord::Migration
  def change
    add_column :user_groups, :emblem, :string
  end
end
