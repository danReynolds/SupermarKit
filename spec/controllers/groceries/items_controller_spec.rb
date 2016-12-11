require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe Groceries::ItemsController, type: :controller do
  include_context 'basic user'

  describe 'GET show' do
    subject { get :show, params: { grocery_id: grocery } }

    it 'should return all items for the grocery with the correct fields' do
      items = grocery.items
      subject
      JSON.parse(response.body).map(&:with_indifferent_access)
        .each_with_index do |item, i|
          grocery_item = items[i].grocery_item(grocery)
          groceries_items_attributes = item[:grocery_item]

          expect(item[:name]).to eq items[i].name
          expect(item[:id]).to eq items[i].id
          expect(item[:description]).to eq items[i].description
          expect(item[:links][:self]).to eq item_path(items[i])
          expect(groceries_items_attributes[:id]).to eq grocery_item.id
          expect(groceries_items_attributes[:units]).to eq grocery_item.units
          expect(groceries_items_attributes[:quantity]).to eq(
            grocery_item.quantity.to_f
          )
          expect(groceries_items_attributes[:requester_id]).to eq(
            grocery_item.requester_id
          )
          expect(groceries_items_attributes[:display_name]).to eq(
            grocery_item.display_name
          )
          expect(groceries_items_attributes[:price]).to eq(
            grocery_item.price_or_estimated.format(symbol: false).to_f
          )
        end
    end
  end

  describe 'PATCH update' do
    let(:grocery_params) { { items: [] } }
    subject do
      patch :update, params: { grocery_id: grocery.id, grocery: grocery_params }
    end

    it 'should singularize and capitalize the names of items added' do
      grocery_params[:items] = [{
        name: 'tomatoes',
        groceries_items_attributes: {
          id: nil,
          grocery_id: grocery.id
        }
      }]
      subject
      expect(grocery.reload.items.last.name).to eq 'Tomato'
    end

    it 'should remove unspecified items' do
      expect(grocery.items).to_not be_empty
      subject
      expect(grocery.reload.items).to be_empty
    end

    context 'adding existing items' do
      let(:grocery_params) do
        {
          items: grocery.items.map do |item|
            grocery_item = item.grocery_item(grocery)
            {
              id: item.id,
              name: item.name,
              groceries_items_attributes: {
                quantity: grocery_item.quantity + 1,
                price: (grocery_item.price + 1.to_money).to_f,
                id: grocery_item.id,
                units: 'cup'
              }
            }
          end
        }
      end

      it 'should not change requesters' do
        subject
        grocery.items.each do |item|
          grocery_item = item.grocery_item(grocery)
          expect(grocery_item.requester).to eq grocery_item.reload.requester
        end
      end

      it 'should update item quantity, price, units' do
        item_params = grocery_params[:items]
        subject
        grocery.items.each_with_index do |item, i|
          grocery_item = item.grocery_item(grocery)
          groceries_items_params = item_params[i][:groceries_items_attributes]
          expect(grocery_item.price).to eq groceries_items_params[:price]
          expect(grocery_item.quantity).to eq groceries_items_params[:quantity]
          expect(grocery_item.units).to eq groceries_items_params[:units]
        end
      end

      it 'should use existing items' do
        expect { subject }.to_not change(Grocery, :count)
      end
    end

    context 'adding new items' do
      let(:grocery_params) do
        {
          items: [
            {
              name: 'new item',
              groceries_items_attributes: {
                price: 2,
                quantity: 3,
                units: 'cup',
                id: nil,
                grocery_id: grocery.id
              }
            },
            {
              name: 'new item2',
              groceries_items_attributes: {
                price: 1,
                quantity: 2,
                units: 'tablespoon',
                id: nil,
                grocery_id: grocery.id
              }
            }
          ]
        }
      end

      it 'should create new items with current user as requester' do
        item_params = grocery_params[:items]
        subject
        grocery.items.each_with_index do |item, i|
          groceries_items_params = item_params[i][:groceries_items_attributes]
          grocery_item = item.grocery_item(grocery)
          expect(item.name).to eq Item.format_name(item_params[i][:name])
          expect(grocery_item.price).to eq groceries_items_params[:price]
          expect(grocery_item.quantity).to eq groceries_items_params[:quantity]
          expect(grocery_item.units).to eq groceries_items_params[:units]
          expect(grocery_item.requester).to eq controller.current_user
        end
      end
    end
  end
end
