require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before(:each) do
    @user = create(:user, :full_user)
    login_user
  end

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
