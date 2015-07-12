require 'rails_helper'
require 'support/login_user'

GroceriesController, type: :controller do
  include_context 'login user'

  describe 'GET index' do
    subject { get :index, user_group_id: user_group, format: :json }

    it 'should have a data response' do
      subject
      resp = JSON.parse(response.body)
      expect(resp.has_key?('data')).to eq true
    end

    it 'should return all group groceries' do
      subject
      data = JSON.parse(response.body)['data']
      groceries = user_group.groceries

      expect(data.length).to eq groceries.length

      groceries.each_with_index do |g, i|
        expect(g.id).to eq data[i]['id']
        expect(g.name).to eq data[i]['name']
        expect(g.description).to eq data[i]['description']
        expect(g.items.count).to eq data[i]['count']
        expect(g.total.to_money.format).to eq data[i]['cost']
        expect(g.finished?).to eq data[i]['finished']
      end
    end
  end

  describe 'POST create' do
    grocery_params = { name: "Test", description: "Test" }
    subject { post :create, grocery: grocery_params, user_group_id: user_group }

    it 'should set the default group if nil' do
      expect(controller.current_user.default_group).to be_nil
      subject
      expect(controller.current_user.default_group).to eq user_group
    end
  end

  describe 'PATCH finish' do
    finish_params = {  }
    subject {
      patch :finish,
      id: user_group.groceries.first.id,
      finish: {
        name: 'Next list',
        description: 'Description',
        current_ids: user_group.groceries.first.items.first(1).map(&:id),
        next_ids: user_group.groceries.first.items.map(&:id)[1..-2]
      }
    }

    it 'should finish the current grocery list' do
      grocery = user_group.groceries.first
      expect(grocery.finished?).to eq false
      subject
      expect(grocery.reload.finished?).to eq true
    end

    it 'should remove specified items from current list' do
      grocery = user_group.groceries.first
      current_items = grocery.items.first(1)
      subject
      expect(grocery.reload.items.to_a).to eq current_items
    end

    it 'should add specified items to the next list' do
      next_items = grocery.items[1..-2]
      subject
      new_grocery = user_group.groceries.last
      expect(new_grocery.reload.items.to_a).to eq next_items
    end
  end
end
