require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe UserGroups::UsersController, type: :controller do
  include_context 'basic user'

  describe 'GET show' do
    subject { get :show, params: { user_group_id: user_group } }

    before :each do
      user_group.users << create_list(:user, 3)
    end

    it 'should return all users with balances' do
      subject
      user_response = user_group.users.includes(:user_groups_users).map do |user|
        {
          id: user.id,
          name: user.name,
          balance: user.user_groups_users.find_by_user_group_id(user_group.id).balance.to_f,
          image: user.gravatar_url
        }.with_indifferent_access
      end
      expect(JSON.parse(response.body)).to eq user_response
    end
  end
end
