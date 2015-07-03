require 'rails_helper'

RSpec.describe UserGroup, :type => :model do
  describe 'group groceries' do
    context 'with groceries' do
      let(:user_group) { create(:user_group, :with_groceries) }

      it 'scopes by unfinished' do
        result = user_group.active_groceries
        expect(result).to eq user_group.groceries
      end

      it 'scopes by finished' do
        user_group.groceries.update_all(finished_at: DateTime.now)
        result = user_group.finished_groceries
        expect(result).to eq user_group.groceries
      end
    end
  end

  describe 'privacy scoping' do
    before(:each) do
      @public_group = create(:user_group, :with_groceries, privacy: UserGroup::PUBLIC)
      @public_group2 = create(:user_group, :with_groceries, privacy: UserGroup::PUBLIC)
      @private_group = create(:user_group, :with_groceries, privacy: UserGroup::PRIVATE)
    end

    context 'public group' do
      it 'should filter by public user groups' do
        expect(UserGroup.public.length).to eq 2
      end

      it 'should return all public items for a public group' do
        items = @public_group.items.merge(@public_group2.items)
        expect(@public_group.privacy_items).to eq items
      end
    end

    context 'private group' do
      it 'should filter by private user groups' do
        expect(UserGroup.private.length).to eq 1
      end

      it 'should return all public items for a private group' do
        expect(@private_group.privacy_items).to eq @private_group.items
      end
    end
  end

  describe 'invitations' do
    before(:each) do
      @user_group = create(:user_group, :with_users)
      @accepted_user = @user_group.users.first
      @invited_user = @user_group.users.last
      @user_group.user_groups_users.find_by_user_id(@accepted_user.id).update_attribute(:state, UserGroupsUsers::ACCEPTED)
    end

    it 'should find all accepted users' do
      expect(@user_group.accepted_users).to eq [@accepted_user]
    end

    it 'should determine the correct state for users' do
      expect(@user_group.user_state(@accepted_user)).to eq UserGroupsUsers::ACCEPTED
      expect(@user_group.user_state(@invited_user)).to eq UserGroupsUsers::INVITED
    end
  end
end
