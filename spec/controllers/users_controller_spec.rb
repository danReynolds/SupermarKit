require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:id) { user.id }
  it_should_behave_like 'routes', {
    new: {},
    show: { id: true, login: true },
    edit: { id: true, login: true }
  }

  describe 'GET auto_complete' do
    include_context 'basic user'

    let(:data) { JSON.parse(response.body)['data'] }

    it 'returns successful match' do
      get :auto_complete, params: { q: controller.current_user.name }
      expect(data.length).to eq 1
    end

    it 'returns nothing for unsuccessful match' do
      get :auto_complete, params: { q: '#' }
      expect(data.length).to eq 0
    end
  end

  describe 'GET activate' do
    let(:user) { create(:user, password: 'valid_password') }
    subject { get :activate, params: { id: user.activation_token } }

    context 'when valid' do
      it 'logs in user from correct token' do
        subject
        expect(controller.current_user).to eq user.reload
      end

      it 'redirects to the user groups' do
        expect(subject).to redirect_to user_groups_path
      end
    end

    context 'when invalid' do
      it 'fails to activate user from invalid token' do
        get :activate, params: { id: user.id }
        expect(controller.current_user).to eq nil
      end
    end
  end

  describe 'POST create' do
    context 'when valid' do
      subject { post :create, params: { user: attributes_for(:user) } }
      it 'should create the user' do
        expect { subject }.to change(User, :count).by 1
      end

      it 'should redirect to homepage' do
        expect(subject).to redirect_to root_path
      end
    end

    context 'when invalid' do
      subject { post :create, params: { user: { name: '' } } }

      it 'should not create a user' do
        expect { subject }.to_not change(User, :count)
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'PATCH default_group' do
    include_context 'basic user'
    let(:user) { controller.current_user }
    subject { patch :default_group, params: { id: user, user_group: @user_group.id } }

    it 'should set that user group as the default for the user' do
      @user_group = create(:user_group)
      user.user_groups << @user_group

      expect(user.default_group).to eq nil
      subject
      expect(user.reload.default_group).to eq @user_group
    end
  end

  describe 'PATCH update' do
    include_context 'basic user'
    let(:user) { controller.current_user }

    it 'should update the user when valid' do
      patch :update, params: { id: user, user: { name: 'Updated User' } }
      expect(user.reload.name).to eq 'Updated User'
    end

    it 'should render edit when invalid' do
      patch :update, params: { id: user, user: { name: '' } }
      expect(response).to have_http_status :unprocessable_entity
      expect(user.name).to eq user.reload.name
    end
  end
end
