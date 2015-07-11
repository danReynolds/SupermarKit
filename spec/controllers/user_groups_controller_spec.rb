require 'rails_helper'
require 'support/login_user'

RSpec.describe UserGroupsController, type: :controller do
  include_context 'login user'

  describe 'POST create' do

    before :each do
      @group_member = create(:user)
      post :create, user_group: attributes_for(:user_group).merge!(user_ids: "#{@group_member.id}")
      @new_group = UserGroup.last
    end

    it 'adds specified and current user to group' do
      expect(@new_group.users).to contain_exactly(@group_member, controller.current_user)
    end

    it 'sets an emblem' do
      expect(@new_group.emblem).not_to be_nil
    end

    it 'makes only the current user accepted into the group' do
      current_group_user = @new_group.user_groups_users.find_by_user_id(controller.current_user.id)
      remaining_user_group_users = @new_group.user_groups_users - [current_group_user]
      expect(current_group_user.state).to eq(UserGroupsUsers::ACCEPTED)

      remaining_user_group_users.each do |user_group_user|
        expect(user_group_user.state).to eq(UserGroupsUsers::INVITED)
      end
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

  describe 'PATCH accept_invitation' do

    it 'should accept the invitation and change UserGroupUser state' do
      user = create(:user)
      user2 = controller.current_user
      user_group = create(:user_group)

      user_group.users << [user, user2]
      user_group.user_groups_users.find_by_user_id(user.id).update_attribute(:state, UserGroupsUsers::ACCEPTED)
      user_group_user = user_group.user_groups_users.find_by_user_id(user2.id)

      expect(user_group_user.state).to eq(UserGroupsUsers::INVITED)
      patch :accept_invitation, id: user_group.id
      expect(user_group_user.reload.state).to eq(UserGroupsUsers::ACCEPTED)
    end
  end
end
