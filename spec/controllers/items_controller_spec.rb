require 'rails_helper'
require 'support/basic_user'

RSpec.describe ItemsController, type: :controller do
  include_context 'basic user'

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
    subject { patch :update, params: valid_params }

    it 'should update the item' do
      subject
      grocery_item.reload
      groceries_items_params = valid_params[:item][:groceries_items_attributes]
      expect(grocery_item.price.to_i).to eq groceries_items_params[:price]
      expect(grocery_item.quantity).to eq groceries_items_params[:quantity]
      expect(grocery_item.units).to eq groceries_items_params[:units]
    end

    it 'should successfully return the old and updated values' do
      grocery_item = item.grocery_item(grocery)
      subject
      body = JSON.parse(response.body)
      expect(body['grocery_item']).to eq(
        ActiveModelSerializers::SerializableResource.new(grocery_item).as_json
          .with_indifferent_access
      )
      expect(body['updated_grocery_item']).to eq(
        ActiveModelSerializers::SerializableResource.new(grocery_item.reload)
          .as_json.with_indifferent_access
      )
    end
  end

  describe 'GET auto_complete' do
    let(:data) { JSON.parse(response.body)['data'] }

    it 'returns an item matching the search query' do
      item = grocery.items.first
      get :auto_complete, params: { grocery_id: grocery, q: item.name }

      expect(data.length).to eq 1
      expect(data.first['name']).to eq item.name
    end

    it 'should always return the exact match' do
      items = %w[breads breadst breadliest breading breader bread].map do |name|
        Item.create(name: name).tap do |item|
          grocery.items << item
        end
      end
      item = items.last

      get :auto_complete, params: { grocery_id: grocery, q: item.name }
      expect(data.map { |i| i['id'] }).to include(item.id)
    end

    describe 'scope by privacy' do
      context 'public kit' do
        it 'returns other public group items' do
          group = create(:user_group, :with_groceries)
          item = group.items.first
          get :auto_complete, params: { grocery_id: grocery, q: item.name }
          expect(data.length).to eq 1
        end

        it 'does not return other private group items' do
          group = create(:user_group, :with_groceries, privacy: UserGroup::PRIVATE)
          item = group.items.first
          get :auto_complete, params: { grocery_id: grocery, q: item.name }
          expect(data.length).to eq 0
        end
      end

      context 'private kit' do
        it 'does not return other public group items' do
          user_group.update_attributes(privacy: UserGroup::PRIVATE)
          other_group = create(:user_group, :with_groceries)
          item = other_group.items.first

          get :auto_complete, params: { grocery_id: grocery, q: item.name }
          expect(data.length).to eq 0
        end

        it 'returns own private group items' do
          user_group.update_attributes(privacy: UserGroup::PRIVATE)
          items = user_group.items - grocery.items

          get :auto_complete, params: { grocery_id: grocery, q: items.first.name }
          expect(data.length).to eq 1
        end
      end
    end
  end
end
