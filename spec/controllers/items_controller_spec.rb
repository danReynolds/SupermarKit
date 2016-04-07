require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

RSpec.describe ItemsController, type: :controller do
  include_context 'basic user'

  let(:id) { grocery.items.first.id }
  let(:grocery_id) { grocery.id }
  it_should_behave_like 'routes', {
    new: { grocery_id: true },
    show: { id: true },
    edit: { id: true },
    create: { method: :post, grocery_id: true }
  }

  describe 'GET index' do
    subject { get :index, grocery_id: grocery, format: :json }

    it 'should return all items for the grocery' do
      subject
      items = JSON.parse(response.body)['data']['items']
      expect(items.length).to eq grocery.items.length
    end

    it "should return the total cost of the grocery's items" do
      subject
      returned_total = JSON.parse(response.body)['data']['total']
      expected_total = grocery.items.inject(0) do |acc, item|
        acc + item.grocery_item(grocery).total_price.to_i
      end

      expect(returned_total).to eq expected_total
    end
  end

  describe 'PATCH update' do
    let(:item) { grocery.items.last }
    let(:grocery_item) { item.grocery_item(grocery) }
    let(:valid_params) {
      {
        grocery_id: grocery.id,
        id: item.id,
        item: {
          groceries_items_attributes: {
            id: grocery_item.id,
            quantity: grocery_item.quantity + 1,
            price: grocery_item.price.to_i + 1
          }
        }
      }
    }
    let(:invalid_params) {
      {
        grocery_id: grocery.id,
        id: item.id,
        item: {
          groceries_items_attributes: {
            id: grocery_item.id,
            quantity: "invalid"
          }
        }
      }
    }

    context 'when valid' do
      subject { patch :update, valid_params, format: :json }

      it 'should update the item' do
        subject
        grocery_item.reload
        expect(grocery_item.price.to_i).to eq valid_params[:item][:groceries_items_attributes][:price]
        expect(grocery_item.quantity).to eq valid_params[:item][:groceries_items_attributes][:quantity]
      end

      it 'should successfully return the old and updated values' do
        expect(subject).to be_ok
        expect(JSON.parse(response.body)['data']['previous_item_values'])
          .to eq controller.send(:format_item, grocery_item)
          .slice(:price, :quantity).with_indifferent_access
        expect(JSON.parse(response.body)['data']['updated_item_values'])
          .to eq controller.send(:format_item, grocery_item.reload)
          .slice(:price, :quantity, :quantity_formatted).with_indifferent_access
      end
    end

    context 'when invalid' do
      subject { patch :update, invalid_params, format: :json }

      it 'should not update the item' do
        subject

        previous_price = grocery_item.price
        previous_quantity = grocery_item.quantity
        grocery_item.reload

        expect(response).to have_http_status :internal_server_error
        expect(grocery_item.price).to eq previous_price
        expect(grocery_item.quantity).to eq previous_quantity
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
    let(:new_item_name) { 'Schnitzel' }
    let(:item) { create(:item) }

    context 'new item' do
      subject { patch :add, grocery_id: grocery, items: { ids: [new_item_name] } }
      it 'should create the new item' do
        expect { subject }.to change(Item, :count).by(1)
      end

      it 'should set the new item price to zero' do
        subject
        expect(Item.last.grocery_item(grocery).price_cents).to eq 0
      end
    end

    context 'existing item' do
      subject { patch :add, grocery_id: grocery, items: { ids: [item.id] } }

      context 'without a store' do
        before(:each) do
          groceries = create_list :grocery, 3, items: [item]
          item.grocery_item(groceries[0]).update_attribute(:price_cents, 500)
          item.grocery_item(groceries[1]).update_attribute(:price_cents, 100)
          item.grocery_item(groceries[2]).update_attribute(:price_cents, 500)
        end

        it 'should assign the overall most common price' do
          subject
          expect(item.reload.grocery_item(grocery).price_cents).to eq 500
        end
      end

      context 'with a store' do
        let(:nearby_store) { create(:grocery_store) }
        before(:each) do
          grocery.update_attribute(:grocery_store, nearby_store)
          groceries = create_list :grocery, 3, items: [item], grocery_store: nearby_store
          item.grocery_item(groceries[0]).update_attribute(:price_cents, 500)
          item.grocery_item(groceries[1]).update_attribute(:price_cents, 100)
          item.grocery_item(groceries[2]).update_attribute(:price_cents, 500)

          other_groceries = create_list :grocery, 3, items: [item]
          other_groceries.each do |grocery|
            item.grocery_item(grocery).update_attribute(:price_cents, 50)
          end
        end

        context 'with a nearby store' do
          it 'should assign the most common price from the nearby store' do
            subject
            expect(item.reload.grocery_item(grocery).price_cents).to eq 500
          end
        end

        context 'without a nearby store' do
          let(:nearby_store) { nil }
          it 'should fallback on the general most common price' do
            subject
            expect(item.reload.grocery_item(grocery).price_cents).to eq 50
          end
        end
      end
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
