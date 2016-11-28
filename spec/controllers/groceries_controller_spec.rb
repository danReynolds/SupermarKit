require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe GroceriesController, type: :controller do
  include_context 'basic user'

  let(:id) { grocery.id }
  let(:user_group_id) { user_group.id }
  it_should_behave_like 'routes', {
    new: { user_group_id: true },
    show: { id: true },
    receipt: { id: true }
  }

  describe 'POST create' do
    let(:grocery_params) {
      {
        name: 'Test',
        description: 'Test'
      }
    }
    subject { post :create, params: { grocery: grocery_params, user_group_id: user_group } }

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
  end

  describe 'POST upload_receipt' do
    let(:subject) { post :upload_receipt, params: { id: grocery.id } }
    # Add additional text at the end of items to test the regex
    let(:processed_receipt) {
      [
        'BACON 54545845454 4.45',
        'LEMON 3.25',
        'BREAD 545458454544 3.20'
      ].join("\n")
    }

    before :each do
      file = double('file')
      allow(file).to receive(:path) {}
      allow_any_instance_of(GroceriesController).to receive(:open).and_return(file)
      allow_any_instance_of(Tesseract::Engine).to receive(:text_for).and_return(processed_receipt)
    end

    context 'with matching item on list' do
      it 'should prioritize list items' do
        expected_matches = [{ name: 'Breed', price: 3.2 }].map(&:stringify_keys)
        Item.create(name: 'Bread')
        grocery.items << Item.create(name: 'Breed')

        subject
        results = JSON.parse(response.body)['data']

        expect(results['total']).to eq 0
        expect(results['matches'].map! { |match| match.slice('name', 'price', 'new') }).to eq expected_matches
      end
    end

    context 'with duplicate matching items on list' do
      let(:processed_receipt) {
        [
          'BACON 54545845454 4.45',
          'BACON 54545845454 4.45',
          'LEMON 3.25',
          'BREAD 545458454544 3.20'
        ].join("\n")
      }

      it 'should aggregate the cost to a single item' do
        expected_matches = [{ name: 'Bacon', price: 8.90, new: true }].map(&:stringify_keys)
        Item.create(name: 'Bacon')

        subject
        results = JSON.parse(response.body)['data']

        expect(results['total']).to eq 0
        expect(results['matches'].map! { |match| match.slice('name', 'price', 'new') }).to eq expected_matches
      end
    end

    context 'without matching item on list' do
      it 'should fallback to all items' do
        expected_matches = [{ name: 'Breed', price: 3.2, new: true }].map(&:stringify_keys)
        Item.create(name: 'Breed')

        subject
        results = JSON.parse(response.body)['data']

        expect(results['total']).to eq 0
        expect(results['matches'].map! { |match| match.slice('name', 'price', 'new') }).to eq expected_matches
      end
    end

    context 'with a total keyword' do
      let(:processed_receipt) {
        [
          "#{GroceriesController::TOTAL_KEYWORDS.first.upcase} 44.45"
        ].join('\n')
      }

      it 'should prioritize matching the total keywords' do
        expected_matches = []
        Item.create(name: GroceriesController::TOTAL_KEYWORDS.first)

        subject
        results = JSON.parse(response.body)['data']

        expect(results['total']).to eq 44.45
        expect(results['matches'].map! { |match| match.slice('name', 'price') }).to eq expected_matches
      end
    end

    context 'with multiple total keywords' do
      let(:processed_receipt) {
        [
          "#{GroceriesController::TOTAL_KEYWORDS.first.upcase} 4.45",
          "#{GroceriesController::TOTAL_KEYWORDS.last.upcase} 10.40"
        ].join("\n")
      }

      it 'should select the highest value total keyword' do
        expected_matches = []
        Item.create(name: GroceriesController::TOTAL_KEYWORDS.first)

        subject
        results = JSON.parse(response.body)['data']

        expect(results['total']).to eq 10.40
        expect(results['matches'].map! { |match| match.slice('name', 'price') }).to eq expected_matches
      end
    end
  end

  describe 'POST confirm_receipt' do
    let(:subject) { patch :confirm_receipt, params: { id: grocery.id, grocery: grocery_params } }
    let(:grocery_params) {
      {
        matches: [
          {
            name: 'Bacon',
            price: 4.00
          }
        ]
      }
    }

    it "should return the uploader's id as the payer" do
      subject
      expect(JSON.parse(response.body)).to eq({
        data: {
          uploader_id: controller.current_user.id
        }
      }.with_indifferent_access)
    end

    context 'with an existing item' do
      let (:name) { 'Bacon' }
      let(:item) { create(:item, name: name) }
      context 'with the item on the grocery list' do
        it 'should set the price of the item to the match price' do
          grocery.items << item
          subject
          expect(item.grocery_item(grocery).price).to eq 4.00.to_money
        end
      end

      context 'with the item not on the grocery list' do
        it 'should add the item to the list with the correct price' do
          expect(grocery.items.find_by_id(item.id)).to eq nil
          subject
          expect(item.grocery_item(grocery).price).to eq 4.00.to_money
          expect(grocery.items.find_by_name(name)).to eq item
        end
      end
    end

    context 'without an existing item' do
      it 'should create the item and add it to the grocery list with the correct price' do
        name = 'Bacon'
        expect(Item.find_by_name(name)).to eq nil
        subject
        item = Item.find_by_name(name)
        expect(item.grocery_item(grocery).price).to eq 4.00.to_money
        expect(grocery.items.find_by_name(name)).to eq item
      end
    end
  end

  describe 'PATCH update_recipes' do
    let(:recipe) { create(:recipe, :with_items) }
    let(:subject) { patch :update_recipes, params: { id: grocery.id, grocery: grocery_params } }
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

    it 'should remove old recipe items and add new ones' do
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

    context 'adding a new recipe' do
      before(:each) do
        grocery_params[:recipes] << {
          name: 'new recipe',
          url: 'http://newrecipe.com',
          items: [
            'Ground pepper',
            'Potato',
            'Tomato'
          ],
          ingredientLines: [
            '2.5 cups of fresh ground peppers',
            '4 potatoes',
            'tomatoes'
          ]
        }
      end

      it 'should not create an item if one by that name already exists' do
        grocery_params[:recipes].last[:items].each do |item_name|
          create(:item, name: item_name)
        end
        expect { subject }.to_not change(Item, :count)
      end

      it 'should not add an item to a list if it is already on the list' do
        grocery_params[:recipes].last[:items].each do |item_name|
          grocery.items << create(:item, name: item_name)
        end
        expect { subject }.to_not change(Item, :count)
      end

      it 'should match items to ingredient lines including units and quantity' do
        item_results = [
          {
            name: 'Ground pepper',
            quantity: 2.5,
            units: 'cup'
          },
          {
            name: 'Potato',
            quantity: 4,
          },
          {
            name: 'Tomato',
            quantity: 1
          }
        ]
        subject
        Recipe.last.items.each_with_index do |item, index|
          grocery_item = item.grocery_item(grocery)
          expect(item.name).to eq item_results[index][:name]
          expect(grocery_item.quantity).to eq item_results[index][:quantity]
          expect(grocery_item.units).to eq item_results[index][:units]
        end
      end

      it 'should recover from unparseable ingredient amounts' do
        grocery_params[:recipes].last[:ingredientLines][0] = 'ground peppers'
        item_results = [
          {
            name: 'Ground pepper',
            quantity: 1
          },
          {
            name: 'Potato',
            quantity: 4,
          },
          {
            name: 'Tomato',
            quantity: 1
          }
        ]
        subject
        Recipe.last.items.each_with_index do |item, index|
          grocery_item = item.grocery_item(grocery)
          expect(item.name).to eq item_results[index][:name]
          expect(grocery_item.quantity).to eq item_results[index][:quantity]
          expect(grocery_item.units).to eq item_results[index][:units]
        end
      end

      it 'should handle ingredient lines with containers' do
        grocery_params[:recipes].last[:ingredientLines][0] = '1 15.5 oz can of ground pepper'
        item_results = [
          {
            name: 'Ground pepper',
            quantity: 15.5,
            units: 'ounce'
          },
          {
            name: 'Potato',
            quantity: 4,
          },
          {
            name: 'Tomato',
            quantity: 1
          }
        ]
        subject
        Recipe.last.items.each_with_index do |item, index|
          grocery_item = item.grocery_item(grocery)
          expect(item.name).to eq item_results[index][:name]
          expect(grocery_item.quantity).to eq item_results[index][:quantity]
          expect(grocery_item.units).to eq item_results[index][:units]
        end
      end

      it 'should add the new recipe to the grocery' do
        expect { subject }.to change(Recipe, :count).by(1)
        expect(grocery.reload.recipes.last).to eq Recipe.last
      end

      it "should create the new recipe's items" do
        expect { subject }.to change(Item, :count).by(3)
        expect(grocery.reload.recipes.last.items).to eq Item.all.last(3)
      end

      it "should add the new recipe's items to the grocery list" do
      end
    end
  end

  describe 'PATCH update_items' do
    let(:grocery_params) {
        { name: grocery.name }
    }
    subject { patch :update_items, params: { id: grocery.id, grocery: grocery_params } }

    it 'should singularize and capitalize the names of items added' do
      grocery_params.merge!({
        items: [{ name: 'tomatoes' }]
      })
      subject
      expect(grocery.reload.items.last.name).to eq 'Tomato'
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
              price: (item.grocery_item(grocery).price + 1.to_money).to_f,
              units: 'cup'
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

      it 'should update item quantity, price, units' do
        subject
        grocery.items.each_with_index do |item, i|
          grocery_item = item.grocery_item(grocery)
          expect(grocery_item.price).to eq grocery_params[:items][i][:price]
          expect(grocery_item.quantity).to eq grocery_params[:items][i][:quantity]
          expect(grocery_item.units).to eq grocery_params[:items][i][:units]
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
            quantity: 3,
            units: 'cup'
          },
          {
            name: 'new item2',
            price: 1,
            quantity: 2,
            units: 'tablespoon'
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
          expect(grocery_item.units).to eq item_params[i][:units]
          expect(grocery_item.requester).to eq controller.current_user
        end
      end
    end
  end

  describe 'PATCH do_checkout' do
    subject { patch :do_checkout, params: params }
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

    context 'slack messages' do
      before :each do
        @slack_bot = create(:slack_bot, :with_messages)
        allow(@slack_bot).to receive(:send_message)
        allow(Grocery).to receive(:find).and_return(grocery)
        allow(grocery).to receive_message_chain(:save!).and_return(true)
        allow(grocery).to receive_message_chain(:user_group, :slack_bot).and_return(@slack_bot)
      end

      context 'with a slackbot' do
        context 'with a receipt' do
          it 'should send a receipt and checkout message' do
            allow(grocery).to receive_message_chain(:receipt, :present?).and_return(true)

            subject
            expect(@slack_bot).to have_received(:send_message)
            .with(SlackMessage::SEND_CHECKOUT_MESSAGE, grocery)
            expect(@slack_bot).to have_received(:send_message)
            .with(SlackMessage::SEND_GROCERY_RECEIPT, grocery)
          end
        end

        context 'without a receipt' do
          it 'should send a checkout message' do
            subject
            expect(@slack_bot).to have_received(:send_message)
            .with(SlackMessage::SEND_CHECKOUT_MESSAGE, grocery)
          end
        end
      end

      context 'without a slackbot' do
        it 'should not send any slack messages' do
          allow(grocery).to receive_message_chain(:user_group, :slack_bot).and_return(nil)
          subject
          expect(@slack_bot).to_not have_received(:send_message)
          .with(SlackMessage::SEND_CHECKOUT_MESSAGE, grocery)
          expect(@slack_bot).to_not have_received(:send_message)
          .with(SlackMessage::SEND_GROCERY_RECEIPT, grocery)
        end
      end
    end


    context 'with every user contributing' do
      it 'should create payments for each user' do
        payment_double = class_double('GroceryPayment').as_stubbed_const

        grocery.user_group.users.each_with_index do |user, i|
          expect(payment_double).to receive(:create).with(
            'grocery_id': grocery.id,
            'user_id': user.id,
            'price': params[:grocery][:payments][i][:price]
          )
        end

        subject
      end

      it 'should create the correct number of payments' do
        expect { subject }.to change(GroceryPayment, :count).by 2
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
        payment_double = class_double('GroceryPayment').as_stubbed_const

        grocery.user_group.users.first(1).each_with_index do |user, i|
          expect(payment_double).to receive(:create).with(
            'grocery_id': grocery.id,
            'user_id': user.id,
            'price': params[:grocery][:payments][i][:price]
          )
        end

        subject
      end

      it 'should create the correct number of payments' do
        expect { subject }.to change(GroceryPayment, :count).by 1
      end
    end

  end

  describe 'POST email_group' do
    before(:each) do
      @users = create_list(:user, 3)
      ActionMailer::Base.deliveries = []
    end

    subject {
      post :email_group, params: {
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
      params: params
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
        expect(subject).to have_http_status :internal_server_error
      end
    end
  end
end
