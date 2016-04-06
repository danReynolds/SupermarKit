require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe UserGroupsController, type: :controller do
  include_context 'basic user'

  let(:id) { user_group }
  it_should_behave_like 'routes', {
    metrics: { id: true },
    edit: { id: true },
    show: { id: true },
    new: {}
  }

  describe 'POST create' do
    let(:user_group_params) { attributes_for(:user_group) }
    let(:subject) { post :create, user_group: user_group_params.merge!(user_ids: "#{group_member.id}") }
    let(:group_member) { create(:user) }
    let(:new_group) { UserGroup.last }

    context 'with valid params' do
      it 'creates the new group' do
        expect { subject }.to change(UserGroup, :count).by(1)
      end

      it 'adds specified and current user to group' do
        subject
        expect(new_group.users).to contain_exactly(group_member, controller.current_user)
      end

      it 'sets an emblem' do
        subject
        expect(new_group.emblem).not_to be_nil
      end

      it 'sets the default group if user does not have one' do
        controller.current_user.update_attribute(:default_group, nil)
        subject
        expect(controller.current_user.default_group).to eq new_group
      end

      it 'keeps the default group if user does have one' do
        default_group = create(:user_group)
        controller.current_user.update_attribute(:default_group, default_group)
        subject
        expect(controller.current_user.default_group).to eq default_group
      end

      it 'makes only the current user accepted into the group' do
        subject
        current_group_user = new_group.user_groups_users.find_by_user_id(controller.current_user.id)
        remaining_user_group_users = new_group.user_groups_users - [current_group_user]
        expect(current_group_user.state).to eq(UserGroupsUsers::ACCEPTED)

        remaining_user_group_users.each do |user_group_user|
          expect(user_group_user.state).to eq(UserGroupsUsers::INVITED)
        end
      end
    end

    context 'with invalid params' do
      it 'should render the new template' do
        user_group_params[:name] = nil
        expect(subject).to render_template :new
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

  describe 'POST accept_invitation' do
    it 'should accept the invitation and change UserGroupUser state' do
      user = create(:user)
      user2 = controller.current_user
      user_group = create(:user_group)

      user_group.users << [user, user2]
      user_group.user_groups_users.find_by_user_id(user.id).update_attribute(:state, UserGroupsUsers::ACCEPTED)
      user_group_user = user_group.user_groups_users.find_by_user_id(user2.id)

      expect(user_group_user.state).to eq(UserGroupsUsers::INVITED)
      post :accept_invitation, id: user_group.id
      expect(user_group_user.reload.state).to eq(UserGroupsUsers::ACCEPTED)
    end
  end
end
