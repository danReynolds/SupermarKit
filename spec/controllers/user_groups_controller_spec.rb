require 'rails_helper'
require 'support/login_user'

RSpec.describe UserGroupsController, type: :controller do
  include_context 'login user'

  describe 'POST create' do

    it 'adds specified and current user to group' do
      group_member = create(:user)
      post :create, user_group: attributes_for(:user_group).merge!(user_ids: "#{group_member.id}")
      new_group = UserGroup.last
      expect(new_group.users).to contain_exactly(group_member, controller.current_user)
    end
  end

  describe 'PATCH update' do

    it 'replaces users with new ones' do
      group = create(:user_group)
      user1 = create(:user)
      user2 = create(:user)
      group.update_attribute(:users, [user1, controller.current_user])
      patch :update, id: group, user_group: { user_ids: "#{controller.current_user.id},#{user2.id}"}
      expect(group.reload.users).to contain_exactly(controller.current_user, user2)
    end
  end
end
