require 'rails_helper'

RSpec.describe UserSessionsController, type: :controller do
  before(:each) do
    @user = create(:user, password: 'valid')
    @user.activate!
  end

  it 'logs user in when valid' do
    post :create, session: { email: @user.email, password: 'valid' }
    expect(controller.current_user).to eq @user.reload
  end

  it 'renders new when invalid' do
    post :create, session: { email: @user.email, password: 'invalid' }
    expect(response).to render_template :new
  end
end
