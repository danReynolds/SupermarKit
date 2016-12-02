require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe PagesController, type: :controller do
  it_should_behave_like 'routes', {
    about: {}
  }

  describe 'GET home' do
    subject { get :home }

    context 'logged in' do
      include_context 'basic user'

      context 'with default group' do
        before :each do
          user_group.user_defaults << controller.current_user
        end

        context 'with active grocery' do
          it 'should redirect to active grocery' do
            expect(subject).to redirect_to user_group.active_groceries.first
          end
        end

        context 'without active grocery' do
          it 'should redirect to default group' do
            user_group.groceries = []
            expect(subject).to redirect_to user_group
          end
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
end
