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
end
