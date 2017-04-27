require 'rails_helper'

describe OauthsController, type: :controller do

  describe 'GET callback' do
    let(:user) { create(:user) }

    context 'with existing user' do
      it 'Should redirect to kit successfully' do
        expect_any_instance_of(OauthsController).to receive(:login_from).with('provider').and_return(user)
        get :callback, params: { provider: 'provider' }

        expect(response).to redirect_to root_path
        expect(flash[:notice]).to_not be_present
      end
    end

    context 'with existing email' do
      it 'should login using the account for the existing email' do
        expect_any_instance_of(OauthsController).to receive(:login_from).with('github').and_return(nil)
        expect_any_instance_of(OauthsController).to receive(:sorcery_fetch_user_hash).and_return(
          user_info: { email: 'test@test.com' }
        )
        expect(User).to receive(:find_by_email).and_return(user)
        get :callback, params: { provider: 'github', code: '123' }

        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to_not be_present
      end
    end

    context 'without existing user' do
      it 'Should create a user and activate the user' do
        expect_any_instance_of(OauthsController).to receive(:sorcery_fetch_user_hash).and_return(
          user_info: { email: 'test@test.com' }
        )
        expect_any_instance_of(OauthsController).to receive(:login_from).with('github').and_return(nil)
        expect_any_instance_of(OauthsController).to receive(:create_from).and_return(user)
        expect(User).to receive(:find_by_email).and_return(nil)
        get :callback, params: { provider: 'github', code: '123' }

        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to be_present
      end
    end

    context 'with failure' do
      it 'Should handle failure to create accounts from oauth and inform the user' do
        expect_any_instance_of(OauthsController).to receive(:sorcery_fetch_user_hash).and_return(
          user_info: { email: 'test@test.com' }
        )
        expect_any_instance_of(OauthsController).to receive(:login_from).with('github').and_return(nil)
        expect_any_instance_of(OauthsController).to receive(:create_from).and_raise(Exception)

        get :callback, params: { provider: 'github', code: '123' }

        expect(response).to redirect_to login_path
        expect(flash[:notice]).to be_present
      end
    end
  end
end
