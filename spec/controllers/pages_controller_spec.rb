require 'rails_helper'
require 'support/login_user'

describe PagesController, type: :controller do
  describe 'GET home' do
    subject { get :home }

    context 'logged in' do
      include_context 'login user'

      context 'with default group' do
        it 'should redirect to active grocery if present' do
          controller.current_user.update_attribute(:default_group, user_group)
          expect(subject).to redirect_to user_group.active_groceries.first
        end

        it 'should redirect to all user groups' do
          expect(subject).to redirect_to user_groups_path
        end
      end

      context 'without default group' do
        it 'should redirect to all user groups' do
          expect(subject).to redirect_to user_groups_path
        end
      end
    end

    context 'not logged in' do
      it 'should not redirect' do
        expect(subject).to be_ok
      end
    end
  end

  describe 'GET about' do
    it 'should be successful' do
      get :about
      expect(response).to be_ok
    end
  end
end
