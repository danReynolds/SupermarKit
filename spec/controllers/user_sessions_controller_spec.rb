require 'rails_helper'

RSpec.describe UserSessionsController, type: :controller do
  it 'logs user in when valid' do
    user = create(:user, password: 'valid')
    post :create, session: { email: user.email, password: 'valid' }
    expect(response).to redirect_to '/user_groups'
  end

  it 'renders new when invalid' do
    user = create(:user, password: 'valid')
    post :create, session: { email: user.email, password: 'invalid' }
    expect(response).to render_template :new
  end
end
