class AddDefaultToCryptedPassword < ActiveRecord::Migration
  def up
    change_column :users, :crypted_password, :string, default: nil, null: true
    change_column :users, :salt, :string, default: nil, null: true
  end

  def down
  end
end
