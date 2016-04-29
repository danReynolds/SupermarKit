require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe GroceriesController, type: :controller do
  include_context 'basic user'

  let(:id) { grocery.id }
  let(:user_group_id) { user_group.id }
  it_should_behave_like 'routes', {
    new: { user_group_id: true },
    show: { id: true }
  }

  describe 'POST create' do
    let(:grocery_params) {
      {
        name: 'Test',
        description: 'Test'
      }
    }
    subject { post :create, grocery: grocery_params, user_group_id: user_group }

    context 'grocery is valid' do
      it 'should create a new grocery' do
        expect { subject }.to change(Grocery, :count).by 1
      end

      it 'should set the default group if nil' do
        expect(controller.current_user.default_group).to be_nil
        subject
        expect(controller.current_user.default_group).to eq user_group
      end
    end

    context 'grocery is invalid' do
      it 'should render new template' do
        grocery_params[:name] = ""
        expect(subject).to render_template :new
      end
    end
  end

  describe 'PATCH update' do
    let(:grocery_params) {
      {
        name: "#{grocery.name} updated"
      }
    }
    subject { patch :update, id: grocery.id, grocery: grocery_params }

    it 'should update the grocery fields' do
      subject
      old_name = grocery.name
      expect(grocery.reload.name).to eq "#{old_name} updated"
    end

    it 'should remove unspecified items' do
      expect(grocery.items).to_not be_empty
      subject
      expect(grocery.reload.items).to be_empty
    end

    context 'adding existing items' do
      before :each do
        grocery_params.merge!({
          items: grocery.items.map do |item|
            {
              id: item.id,
              name: item.name,
              quantity: item.grocery_item(grocery).quantity + 1,
              price: item.grocery_item(grocery).price + 1.to_money
            }
          end
        })
      end

      it 'should not change requesters' do
        subject
        grocery.items.each do |item|
          grocery_item = item.grocery_item(grocery)
          expect(grocery_item.requester).to eq grocery_item.reload.requester
        end
      end

      it 'should update the quantity and price' do
        subject
        grocery.items.each_with_index do |item, i|
          grocery_item = item.grocery_item(grocery)
          expect(grocery_item.price).to eq grocery_params[:items][i][:price]
          expect(grocery_item.quantity).to eq grocery_params[:items][i][:quantity]
        end
      end

      it 'should use existing items' do
        expect { subject }.to_not change(Grocery, :count)
      end
    end

    context 'adding new items' do
      let(:item_params) {
        [
          {
            name: 'new item',
            price: 2,
            quantity: 3
          },
          {
            name: 'new item2',
            price: 1,
            quantity: 2
          }
        ]
      }

      before :each do
        grocery_params.merge!({
            items: item_params
        })
      end

      it 'should create new items with current user as requester' do
        subject
        grocery.items.each_with_index do |item, i|
          grocery_item = item.grocery_item(grocery)

          expect(item.name).to eq item_params[i][:name].capitalize
          expect(grocery_item.price).to eq item_params[i][:price]
          expect(grocery_item.quantity).to eq item_params[i][:quantity]
          expect(grocery_item.requester).to eq controller.current_user
        end
      end
    end
  end

  describe 'PATCH do_checkout' do
    subject { patch :do_checkout, params }
    let (:payments) { [] }
    let(:params) {
      {
        id: grocery.id,
        grocery: {}
      }
    }

    before :each do
      other_user = create(:user)
      grocery.user_group.users << other_user
      params[:grocery][:payments] = grocery.user_group.users.map.with_index do |user, i|
        {
          user_id: user.id,
          price: i
        }
      end

      @payment_double = class_double('Payment').as_stubbed_const
    end

    it 'should finish the grocery list' do
      expect(grocery.finished?).to eq false
      subject
      expect(grocery.reload.finished?).to eq true
    end

    context 'with every user contributing' do
      it 'should create payments for each user' do
        grocery.user_group.users.each_with_index do |user, i|
          expect(@payment_double).to receive(:create).with(
            hash_including(
              'grocery_id': grocery.id,
              'user_id': user.id.to_s,
              'price': params[:grocery][:payments][i][:price].to_s
            )
          )
        end

        subject
      end
    end

    context 'without every user contributing' do
      it 'should create payments for only contributing users' do
        params[:grocery][:payments] = grocery.user_group.users.first(1).map.with_index do |user, i|
          {
            user_id: user.id,
            price: i
          }
        end

        grocery.user_group.users.first(1).each_with_index do |user, i|
          expect(@payment_double).to receive(:create).with(
            hash_including(
              'grocery_id': grocery.id,
              'user_id': user.id.to_s,
              'price': params[:grocery][:payments][i][:price].to_s
            )
          )
        end

        subject
      end
    end
  end

  describe 'POST email_group' do
    subject { post :email_group, id: grocery.id }

    it 'should deliver an email to each group member' do
      users = grocery.user_group.users
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by users.count
    end

    it 'should redirect to the grocery page' do
      expect(subject).to redirect_to grocery
    end
  end

  describe 'POST set_store' do
    let(:subject) { post :set_store, id: grocery.id, grocery_store: params }
    let(:params) { attributes_for(:grocery_store) }

    context 'when valid params' do
      it 'should finish successfully' do
        expect(subject).to be_ok
      end

      context 'with an existing store' do
        let(:store) { create(:grocery_store) }
        before(:each) { params[:place_id] = store.place_id }

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
          grocery_store = GroceryStore.find_by_place_id(params[:place_id])
          expect(grocery.reload.grocery_store).to eq grocery_store
        end
      end
    end

    context 'when invalid params' do
      it 'should render an error' do
        params[:place_id] = nil
        expect(subject).to have_http_status(:internal_server_error)
      end
    end
  end

  describe 'GET recipes' do
    it 'should be successful' do
      stub_request(:get, /food2fork.com/).
        with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' }).
        to_return(status: 200, body: '{}', headers: {})

      get :recipes, id: grocery.id, format: :json
      expect(response).to be_ok
    end
  end
end
