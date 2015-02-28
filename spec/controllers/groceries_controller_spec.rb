require 'rails_helper'
require 'support/login_user'

RSpec.describe GroceriesController, type: :controller do
  include_context 'login user'

  describe 'GET index' do
    subject { get :index, user_group_id: user_group, format: :json }

    context 'as a usergroup with groceries' do

      it 'should have a data response' do
        subject
        resp = JSON.parse(response.body)
        expect(resp.has_key?('data')).to eq true
      end

      it 'should return all group groceries' do
        subject
        data = JSON.parse(response.body)['data']
        expect(data.map(&:first)).to eq user_group.grocery_ids - [user_group.active_groceries.first.id]
      end
    end
  end

  describe 'PATCH toggle_finish' do
    subject { post :toggle_finish, id: grocery }

    it 'should flip grocery status' do
      subject
      expect(grocery.finished?).to eq !grocery.reload.finished?
    end
  end
end
