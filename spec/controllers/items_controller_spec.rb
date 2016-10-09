require 'rails_helper'
require 'support/basic_user'

RSpec.describe ItemsController, type: :controller do
  include_context 'basic user'

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
        acc + item.grocery_item(grocery).price_or_estimated.to_f
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
            price: grocery_item.price.to_i + 1,
            units: 'cup'
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
        expect(grocery_item.units).to eq valid_params[:item][:groceries_items_attributes][:units]
      end

      it 'should successfully return the old and updated values' do
        subject
        expect(JSON.parse(response.body)['data']['previous_item_values'])
          .to eq controller.send(:format_item, grocery_item)
          .slice(:price).with_indifferent_access
        expect(JSON.parse(response.body)['data']['updated_item_values'])
          .to eq controller.send(:format_item, grocery_item.reload)
          .slice(:price, :quantity, :display_name, :units).with_indifferent_access
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
    let(:data) { JSON.parse(response.body)['data'] }

    it 'returns an item matching the search query' do
      item = grocery.items.first
      get :auto_complete, grocery_id: grocery, q: item.name

      expect(data.length).to eq 1
      expect(data.first['name']).to eq item.name
    end

    it 'should always return the exact match' do
      items = %w[breads breadst breadliest breading breader bread].map do |name|
        item = Item.create(name: name)
        item.tap do |i|
          grocery.items << item
        end
      end
      item = items.last

      get :auto_complete, grocery_id: grocery, q: item.name
      expect(data.map { |i| i['id'] }).to include(item.id)
    end

    describe 'scope by privacy' do
      context 'public kit' do
        it 'returns other public group items' do
          group = create(:user_group, :with_groceries)
          item = group.items.first
          get :auto_complete, grocery_id: grocery, q: item.name
          expect(data.length).to eq 1
        end

        it 'does not return other private group items' do
          group = create(:user_group, :with_groceries, privacy: UserGroup::PRIVATE)
          item = group.items.first
          get :auto_complete, grocery_id: grocery, q: item.name
          expect(data.length).to eq 0
        end
      end

      context 'private kit' do
        it 'does not return other public group items' do
          user_group.update_attributes(privacy: UserGroup::PRIVATE)
          other_group = create(:user_group, :with_groceries)
          item = other_group.items.first

          get :auto_complete, grocery_id: grocery, q: item.name
          expect(data.length).to eq 0
        end

        it 'returns own private group items' do
          user_group.update_attributes(privacy: UserGroup::PRIVATE)
          items = user_group.items - grocery.items

          get :auto_complete, grocery_id: grocery, q: items.first.name
          expect(data.length).to eq 1
        end
      end
    end
  end
end
