class ChangeFinishedToFinishedAt < ActiveRecord::Migration
  def change
    add_column :groceries, :finished_at, :datetime
    remove_column :groceries, :finished
  end
end
