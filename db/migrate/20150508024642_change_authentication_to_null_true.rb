class ChangeAuthenticationToNullTrue < ActiveRecord::Migration
  def change
    change_column :authentications, :user_id, :integer, default: nil, null: true
    change_column :authentications, :provider, :string, default: nil, null: true
    change_column :authentications, :uid, :string, default: nil, null: true
  end
end
