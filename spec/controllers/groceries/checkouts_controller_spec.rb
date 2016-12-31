require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe Groceries::CheckoutsController, type: :controller do
  include_context 'basic user'

  let(:grocery_id) { grocery.id }
  it_should_behave_like 'routes', show: { grocery_id: true }

  describe 'POST create' do
    subject { post :create, params: params }
    let (:payments) { [] }
    let(:params) do
      { grocery_id: grocery_id, grocery: {} }
    end

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
end
