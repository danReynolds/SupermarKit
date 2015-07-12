require 'rails_helper'
require 'support/login_user'

describe GroceriesController, type: :controller do
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
    let(:grocery_params) {
       {
         name: "Test",
         description: "Test"
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
      it 'should redirect to new template' do
        grocery_params[:name] = ""
        expect(subject).to render_template :new
      end
    end
  end

  describe 'PATCH finish' do
    let(:finish_params) {
      {
        name: 'Next list',
        description: 'Description',
        current_ids: user_group.groceries.first.items.first(1).map(&:id),
        next_ids: user_group.groceries.first.items.map(&:id)[1..-2]
      }
    }

    let(:grocery) { user_group.groceries.first }

    subject {
      patch :finish,
      id: user_group.groceries.first.id,
      finish: finish_params
    }

    context 'groceries are valid to finish' do
      it 'should finish the current grocery list' do
        expect(grocery.finished?).to eq false
        subject
        expect(grocery.reload.finished?).to eq true
      end

      it 'should remove specified items from current list' do
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

      it 'should redirect to the newly created grocery' do
        subject
        new_grocery = user_group.groceries.last
        expect(response).to redirect_to new_grocery
      end
    end

    context 'groceries are not both valid' do
      before :each do
        finish_params[:name] = ''
      end

      it 'should not finish the current grocery' do
        subject
        expect(grocery.reload.finished_at).to be_nil
      end

      it 'should not create the new grocery' do
        expect { subject }.to_not change(Grocery, :count)
      end

      it 'should notify that there was a problem' do
        expect(subject).to redirect_to grocery
      end
    end
  end
end
