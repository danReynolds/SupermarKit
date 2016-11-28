require 'rails_helper'

describe OauthsController, type: :controller do

  describe 'GET callback' do
    let(:user) { create(:user) }

    it 'Should redirect to kit successfully if user found' do
      expect_any_instance_of(OauthsController).to receive(:login_from).with('provider').and_return(user)
      get :callback, params: { provider: 'provider' }

      expect(response).to redirect_to root_path
      expect(flash[:notice]).to be_present
    end

    it 'Should create a user and activate it if no existing user is found' do
      expect_any_instance_of(OauthsController).to receive(:login_from).with('github').and_return(nil)
      expect_any_instance_of(OauthsController).to receive(:create_from).and_return(user)
      get :callback, params: { provider: 'github', code: '123' }

      expect(controller.current_user).to eq(user)
      expect(response).to redirect_to user_groups_path
      expect(flash[:notice]).to be_present
    end

    it 'Should handle failure to create accounts from oauth and inform the user' do
      expect_any_instance_of(OauthsController).to receive(:login_from).with('github').and_return(nil)
      expect_any_instance_of(OauthsController).to receive(:create_from).and_raise(Exception)
      get :callback, params: { provider: 'github', code: '123' }

      expect(response).to redirect_to new_user_path
      expect(flash[:alert]).to be_present
    end
  end
end
