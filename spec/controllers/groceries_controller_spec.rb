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

  describe 'PATCH update_recipes' do
    let(:recipe) { create(:recipe, :with_items) }
    let(:subject) { patch :update_recipes, id: grocery.id, grocery: grocery_params }
    let(:grocery_params) {
      {
        name: "#{grocery.name} updated",
        recipes: [
          {
            external_id: recipe.external_id
          }
        ]
      }
    }

    it "should remove the items of the grocery's removed recipes" do
      other_recipe = create(:recipe, :with_items)
      grocery.recipes << other_recipe
      grocery.items << other_recipe.items
      items = Item.find(grocery.item_ids)
      subject
      expect(grocery.reload.items).to match_array(items + recipe.items - other_recipe.items)
    end

    it 'should add the recipe to the grocery' do
      subject
      expect(grocery.reload.recipes.first).to eq recipe
    end

    context 'adding existing recipe' do
      it "should update the grocery's items to include the recipe items" do
        items = Item.find(grocery.item_ids)
        subject
        expect(grocery.reload.items).to match_array(items + recipe.items)
      end

      it 'should use the existing recipe' do
        recipe = create(:recipe)
        grocery_params[:recipes] = [
          {
            external_id: recipe.external_id
          }
        ]
        expect { subject }.to_not change(Recipe, :count)
      end
    end

    context 'adding new recipe' do
      before(:each) do
        grocery_params[:recipes] << {
          name: 'new recipe',
          url: 'http://newrecipe.com',
          items: [{ name: 'new recipe item' }]
        }
      end

      it 'should not create an item if one by that name already exists' do
        create(:item, name: 'new recipe item')
        expect { subject }.to_not change(Item, :count)
      end

      it 'should add the new recipe to the grocery' do
        expect { subject }.to change(Recipe, :count).by(1)
        expect(grocery.reload.recipes.count).to eq 2
      end

      it "should create the new recipe's items and add them to the grocery" do
        items = Item.find(grocery.item_ids)
        expect { subject }.to change(Item, :count).by(1)
        expect(grocery.reload.items).to match_array(items + grocery.recipes.flat_map(&:items).uniq)
      end
    end
  end

  describe 'PATCH update_items' do
    let(:grocery_params) {
      {
        name: "#{grocery.name} updated"
      }
    }
    subject { patch :update_items, id: grocery.id, grocery: grocery_params }

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
    end

    it 'should finish the grocery list' do
      expect(grocery.finished?).to eq false
      subject
      expect(grocery.reload.finished?).to eq true
    end

    context 'with every user contributing' do
      it 'should create payments for each user' do
        payment_double = class_double('Payment').as_stubbed_const

        grocery.user_group.users.each_with_index do |user, i|
          expect(payment_double).to receive(:create).with(
            hash_including(
              'grocery_id': grocery.id,
              'user_id': user.id.to_s,
              'price': params[:grocery][:payments][i][:price].to_s
            )
          )
        end

        subject
      end

      it 'should create the correct number of payments' do
        expect { subject }.to change(Payment, :count).by 2
      end
    end

    context 'without every user contributing' do
      before :each do
        params[:grocery][:payments] = grocery.user_group.users.first(1).map.with_index do |user, i|
          {
            user_id: user.id,
            price: i
          }
        end
      end
      it 'should create payments for only contributing users' do
        payment_double = class_double('Payment').as_stubbed_const

        grocery.user_group.users.first(1).each_with_index do |user, i|
          expect(payment_double).to receive(:create).with(
            hash_including(
              'grocery_id': grocery.id,
              'user_id': user.id.to_s,
              'price': params[:grocery][:payments][i][:price].to_s
            )
          )
        end

        subject
      end

      it 'should create the correct number of payments' do
        expect { subject }.to change(Payment, :count).by 1
      end
    end

  end

  describe 'POST email_group' do
    before(:each) do
      @users = create_list(:user, 3)
      ActionMailer::Base.deliveries = []
    end

    subject {
      post :email_group,
      id: grocery.id,
      grocery: {
        email: {
          user_ids: @users.first(2).map do |user|
            user.id
          end,
          message: 'test message'
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
    let(:subject) {
      patch :update_store,
      params
    }
    let(:params) {
      {
        id: grocery.id,
        grocery: {
          store: attributes_for(:grocery_store)
        }
      }
    }

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
