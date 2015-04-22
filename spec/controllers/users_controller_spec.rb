require 'rails_helper'
require 'support/login_user'

RSpec.describe UsersController, type: :controller do
  
  describe 'GET auto_complete' do
    include_context 'login user'
    
    it 'returns successful match' do
      get :auto_complete, q: controller.current_user.name
      count = JSON.parse(response.body)['total_users']
      expect(count).to eq 1
    end

    it 'returns nothing for unsuccessful match' do
      get :auto_complete, q: '#'
      count = JSON.parse(response.body)['total_users']
      expect(count).to eq 0
    end
  end

  describe 'GET activate' do
    let(:user) { create(:user, password: 'valid') }

    it 'logs in user from correct token' do
      get :activate, id: user.activation_token
      expect(controller.current_user).to eq user.reload
    end

    it 'fails to activate user from invalid token' do
      get :activate, id: user.id
      expect(controller.current_user).to eq nil
    end
  end

  describe 'PATCH default_group' do
    include_context 'login user'
    let(:user_group) { create(:user_group) }

    it 'should update the user group' do
      patch :default_group, id: controller.current_user, default_group_id: user_group.id
      expect(controller.current_user.reload.default_group).to eq user_group
    end
  end

  describe 'PATCH update' do
    include_context 'login user'

    it 'should update the user when valid' do
      patch :update, id: controller.current_user, user: { name: 'Updated User' }
      expect(controller.current_user.reload.name).to eq 'Updated User'
    end
  end
end
