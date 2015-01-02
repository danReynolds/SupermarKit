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
      expect(data.map(&:first)).to eq grocery.item_ids
    end
  end

  describe 'GET auto_complete' do

    it 'returns an item not in current grocery list' do
      items = user_group.items - grocery.items
      get :auto_complete, grocery_id: grocery, q: items.first.name
      resp = JSON.parse(response.body)['total_items']
      expect(resp).to eq 1
    end

    it 'does not return an item in the current grocery list' do
      item = grocery.items.first
      get :auto_complete, grocery_id: grocery, q: item.name
      resp = JSON.parse(response.body)['total_items']
      expect(resp).to eq 0
    end
  end

  describe 'PATCH add' do

    it 'adds items to grocery' do
      new_item = create(:item)
      patch :add, grocery_id: grocery, items: { ids: [new_item.id] }
      expect(grocery.reload.items).to include(new_item)
    end
  end

  describe 'PATCH remove' do

    it 'removes the item from grocery' do
      item = grocery.items.last
      patch :remove, grocery_id: grocery, id: item
      expect(grocery.reload.items).not_to include(item)
    end
  end
end
