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
    it 'logs user in when valid' do
      post :create, session: { email: @user.email, password: 'valid_password' }
      expect(controller.current_user).to eq @user.reload
    end

    it 'renders new when invalid' do
      post :create, session: { email: @user.email, password: 'invalid_password' }
      expect(response).to render_template :new
    end
  end

  describe 'DELETE destroy' do
    it 'should log the user out' do
      delete :destroy
      expect(controller.current_user).to be_nil
    end
  end
end
