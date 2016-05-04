class AddBannerToUserGroup < ActiveRecord::Migration
  def self.up
    add_attachment :user_groups, :banner
  end

  def self.down
    remove_attachment :user_groups, :banner
  end
end
