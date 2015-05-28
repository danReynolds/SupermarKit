class AddEmblemToKit < ActiveRecord::Migration
  def change
    add_column :user_groups, :emblem, :string

    UserGroup.all.each do |g|
      g.update_attribute(:emblem, UserGroup::EMBLEMS.sample)
    end
  end
end
