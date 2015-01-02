require 'rails_helper'
require 'support/login_user'

RSpec.describe UsersController, type: :controller do
  include_context 'login user'
  
  describe 'GET auto_complete' do
    
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
end
