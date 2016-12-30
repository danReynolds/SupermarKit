require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe GroceriesController, type: :controller do
  include_context 'basic user'

  let(:id) { grocery.id }
  let(:user_group_id) { user_group.id }
  it_should_behave_like 'routes', {
    new: { user_group_id: true },
    show: { id: true },
  }

  describe 'POST create' do
    let(:grocery_params) {
      {
        name: 'Test',
        description: 'Test'
      }
    }
    subject do
      post :create, params: {
        grocery: grocery_params, user_group_id: user_group
      }
    end

    context 'grocery is valid' do
      it 'should create a new grocery' do
        expect { subject }.to change(Grocery, :count).by 1
      end

      it 'should set the default group if nil' do
        expect(controller.current_user.default_group).to be_nil
        subject
        expect(controller.current_user.reload.default_group).to eq user_group
      end
    end
  end

  describe 'POST email_group' do
    before(:each) do
      @users = create_list(:user, 3)
      ActionMailer::Base.deliveries = []
    end

    subject {
      post :email_group, params: {
        id: grocery.id,
        grocery: {
          email: {
            user_ids: @users.first(2).map(&:id),
            message: 'test message'
          }
        }
      }
    }

    it 'should deliver an email to each specified member' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by 2
      @users.first(2).each_with_index do |user, i|
        expect(ActionMailer::Base.deliveries[i].to.first).to eq user.email
      end
    end
  end

  describe 'PATCH update_store' do
    let(:store) { create(:grocery_store) }
    let(:subject) do
      patch :update_store,
      params: params
    end
    let(:params) do
      {
        id: grocery.id,
        grocery: {
          store: attributes_for(:grocery_store)
        }
      }
    end

    context 'when valid params' do
      it 'should finish successfully' do
        expect(subject).to be_ok
      end

      context 'with an existing store' do
        before(:each) { params[:grocery][:store][:place_id] = store.place_id }

        it 'should assign the store to the grocery list' do
          subject
          expect(grocery.reload.grocery_store).to eq store
        end

        it 'should not create a new store' do
          expect { subject }.to_not change(GroceryStore, :count)
        end
      end

      context 'with a new store' do
        it 'should create the new store' do
          expect { subject }.to change(GroceryStore, :count).by(1)
        end

        it 'should assign the new store to the grocery list' do
          subject
          grocery_store = GroceryStore.find_by_place_id(params[:grocery][:store][:place_id])
          expect(grocery.reload.grocery_store).to eq grocery_store
        end
      end

      context 'without a store' do
        it 'should clear the grocery store' do
          params[:grocery][:store] = nil
          grocery.grocery_store = store
          grocery.save

          expect(grocery.grocery_store).to eq store
          subject
          expect(grocery.reload.grocery_store).to eq nil
        end
      end
    end

    context 'when invalid params' do
      it 'should render an error' do
        params[:grocery][:store][:place_id] = nil
        expect(subject).to have_http_status :internal_server_error
      end
    end
  end
end
