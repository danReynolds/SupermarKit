class AddPrivacyToUserGroup < ActiveRecord::Migration
  def change
    add_column :user_groups, :privacy, :string
    UserGroup.all.update_all(privacy: "public")
  end
end
