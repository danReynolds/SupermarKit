require 'rails_helper'
require 'support/login_user'

RSpec.describe ItemsController, type: :controller do
  include_context 'login user'

  describe 'GET index' do
    subject { get :index, grocery_id: grocery, format: :json }

    it 'should have a data response' do
      subject
      resp = JSON.parse(response.body)
      expect(resp.has_key?('data')).to eq true
    end

    it 'should return all grocery items' do
      subject
      data = JSON.parse(response.body)['data']

      expect(data.length).to eq grocery.items.length

      grocery.items.each_with_index do |item, i|
        expect(item.id).to eq data[i]['id']
        expect(item.name).to eq data[i]['name']
        expect(item.description.to_s).to eq data[i]['description']
        expect(item.groceries_items.find_by_grocery_id(grocery.id).id).to eq data[i]['quantity_id']
        expect(item.quantity(grocery)).to eq data[i]['quantity']
        expect(item.price.dollars.to_s).to eq data[i]['price']
        expect(item.price.format).to eq data[i]['price_formatted']
        expect(item.total_price(grocery).format).to eq data[i]['total_price_formatted']
        expect(item_path(item.id)).to eq data[i]['path']
      end
    end
  end

  describe 'POST create' do
    context 'when valid item' do
      subject { post :create, item: attributes_for(:item), grocery_id: grocery.id }

      it 'should create a new item' do
        expect { subject }.to change(Item, :count).by 1
      end

      it 'should capitalize the item name' do
        subject
        name = Item.last.name
        expect(name).to eq name.capitalize
      end

      it 'should redirect to the new grocery page' do
        expect(subject).to redirect_to grocery
      end
    end

    context 'when invalid item' do
      subject { post :create, item: { name: '' }, grocery_id: grocery.id }

      it 'should not create a new item' do
        expect { subject }.to_not change(Item, :count)
      end

      it 'should render the new template' do
        expect(subject).to render_template :new
      end
    end
  end

  describe 'PATCH update' do
    let(:item) { grocery.items.last }
    let(:params) {
      {
        name: "#{item.name} updated"
      }
    }

    context 'when HTML' do
      subject { patch :update, id: item.id, item: params }

      context 'when valid' do
        it 'should update the item' do
          subject
          expect(item.reload.name).to eq params[:name]
        end

        it 'should redirect to the user group' do
          expect(subject).to redirect_to user_group
        end
      end

      context 'when invalid' do
        before :each do
          params[:name] = ''
        end

        it 'should not update the item' do
          name = item.name
          subject
          expect(item.reload.name).to eq name
        end

        it 'should render the edit template' do
          expect(subject).to render_template :edit
        end
      end
    end

    context 'when JSON' do
      subject { patch :update, id: item.id, item: params, format: :json }

      context 'when valid' do
        it 'should update the item' do
          subject
          expect(item.reload.name).to eq params[:name]
        end

        it 'should return a valid response' do
          expect(subject).to be_ok
        end
      end

      context 'when invalid' do
        before :each do
          params[:name] = ''
        end

        it 'should not update the item' do
          name = item.name
          subject
          expect(item.reload.name).to eq name
        end

        it 'should return an internal server error' do
          subject
          expect(response).to have_http_status :internal_server_error
        end
      end
    end
  end

  describe 'GET auto_complete' do
    describe 'Scope by presence' do
      it 'returns an item not present in current grocery list' do
        items = user_group.items - grocery.items
        get :auto_complete, grocery_id: grocery, q: items.first.name
        resp = JSON.parse(response.body)['total_items']
        expect(resp).to eq 1
      end

      it 'does not return an item present in the current grocery list' do
        item = grocery.items.first
        get :auto_complete, grocery_id: grocery, q: item.name
        resp = JSON.parse(response.body)['total_items']
        expect(resp).to eq 0
      end
    end

    describe 'Scope by privacy' do
      context 'public kit' do
        it 'returns other public group items' do
          group = create(:user_group, :with_groceries)
          item = group.items.first
          get :auto_complete, grocery_id: grocery, q: item.name
          resp = JSON.parse(response.body)['total_items']
          expect(resp).to eq 1
        end

        it 'does not return other private group items' do
          group = create(:user_group, :with_groceries, privacy: UserGroup::PRIVATE)
          item = group.items.first
          get :auto_complete, grocery_id: grocery, q: item.name
          resp = JSON.parse(response.body)['total_items']
          expect(resp).to eq 0
        end
      end

      context 'private kit' do
        it 'does not return other public group items' do
          user_group.update_attributes(privacy: UserGroup::PRIVATE)
          other_group = create(:user_group, :with_groceries)
          item = other_group.items.first

          get :auto_complete, grocery_id: grocery, q: item.name
          resp = JSON.parse(response.body)['total_items']
          expect(resp).to eq 0
        end

        it 'returns own private group items' do
          user_group.update_attributes(privacy: UserGroup::PRIVATE)
          items = user_group.items - grocery.items

          get :auto_complete, grocery_id: grocery, q: items.first.name
          resp = JSON.parse(response.body)['total_items']
          expect(resp).to eq 1
        end
      end
    end
  end

  describe 'PATCH add' do
      let(:new_item) { create(:item) }
      subject { patch :add, grocery_id: grocery, items: { ids: [new_item.id] } }

    it 'adds items to grocery' do
      subject
      expect(grocery.reload.items).to include(new_item)
    end

    it 'successfully returns' do
      expect(subject).to be_ok
    end
  end

  describe 'PATCH remove' do
    let(:item) { grocery.items.last }
    subject { patch :remove, grocery_id: grocery, id: item }

    it 'removes the item from grocery' do
      subject
      expect(grocery.reload.items).not_to include(item)
    end

    it 'successfully returns' do
      expect(subject).to be_ok
    end
  end
end
