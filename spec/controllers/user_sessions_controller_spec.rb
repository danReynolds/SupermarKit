require 'rails_helper'
require 'support/routes'

describe UserSessionsController, type: :controller do
  before(:each) do
    @user = create(:user, password: 'valid_password')
    @user.activate!
  end

  it_should_behave_like 'routes', {
    new: {}
  }

  describe 'POST create' do
    context 'when valid' do
      it 'logs user in' do
        post :create, params: { user_session: { email: @user.email, password: 'valid_password' } }
        expect(controller.current_user).to eq @user.reload
      end
    end

    context 'when invalid' do
      it 'renders new' do
        post :create, params: { user_session: { email: @user.email, password: 'invalid_password' } }
        expect(controller.current_user).to eq nil
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy }

    context 'not logged in' do
      it 'should redirect to the login page' do
        expect(subject).to redirect_to login_path
      end
    end

    context 'logged in' do
      include_context 'basic user'

      it 'should log the user out' do
        subject
        expect(controller.current_user).to be_nil
      end

      it 'should redirect to the login page' do
        expect(subject).to redirect_to login_path
      end
    end
  end
end
