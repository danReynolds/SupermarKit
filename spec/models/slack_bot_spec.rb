require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    @slack_bot = create(:slack_bot, :with_messages)
  end

  describe '#setup_client' do
    it "should create a new slack client with the the bot's api token" do
      Slack::Web::Client.stub(:new)
      @slack_bot.setup_client
      Slack::Web::Client.should have_received(:new).with(token: @slack_bot.api_token)
    end
  end

  describe '#send_message' do
    it 'should call the message of the given type with the remaining arguments' do
      @slack_bot.stub(:send_grocery_receipt)
      grocery = instance_double('Grocery')
      type = SlackMessage::SEND_GROCERY_RECEIPT

      @slack_bot.send_message(SlackMessage::SEND_GROCERY_RECEIPT, grocery)

      @slack_bot.should have_received(:send_grocery_receipt).with(
        @slack_bot.slack_messages.find_by_message_type(type).format,
        grocery
      )
    end
  end

  describe '#enabled?' do
    context 'with a message of the requested type' do
      it 'should return true' do
        expect(@slack_bot.enabled?(SlackMessage::SEND_GROCERY_RECEIPT)).to eq true
      end
    end

    context 'without a message of the requested type' do
      it 'should return false' do
        @slack_bot.slack_messages.clear
        expect(@slack_bot.enabled?(SlackMessage::SEND_GROCERY_RECEIPT)).to eq false
      end
    end
  end

  describe '#post_message' do
    it 'should post to general with all keys substituted by the formatted values' do
      url = 'https://slack.com/api/chat.postMessage'
      stub_request(:post, url).to_return(
        status: 200,
        headers: {},
        # slack-client-ruby requires a body with ok true returned
        # in order to not throw an error
        body: { ok: true }.to_json,
      )

      @slack_bot.send(
        :post_message,
        'This is a {test} of {substitution}',
        { test: 'working example', substitution: 'the tests passing' }
      )
      expect(WebMock).to have_requested(:post, url).with(
        body: {
          as_user: "true",
          channel: '#general',
          text: 'This is a working example of the tests passing',
          token: ''
        }
      )
    end
  end

  describe '#send_grocery_receipt' do
    it 'should post a receipt message with the receipt url' do
      url = 'https://test.com'
      format = @slack_bot.slack_messages
        .find_by_message_type(SlackMessage::SEND_GROCERY_RECEIPT).format
      @slack_bot.stub(:post_message)
      grocery = instance_double('Grocery')
      allow(grocery).to receive_message_chain(:receipt, :url).and_return(url)

      @slack_bot.send(:send_grocery_receipt, format, grocery)

      @slack_bot.should have_received(:post_message).with(format, { url: url })
    end
  end

  describe '#send_checkout_message' do
    it 'should post a checkout message with the payer, payee and payment info' do
      @slack_bot.stub(:post_message)
      format = @slack_bot.slack_messages
        .find_by_message_type(SlackMessage::SEND_CHECKOUT_MESSAGE).format

      grocery = create(:grocery)
      payer = create(:user)
      payer_payment = GroceryPayment.create(price: 10, user: payer)
      payees = create_list :user, 3
      users = [payer] + payees
      grocery.payments << payer_payment
      payees.each do |payee|
        grocery.payments << GroceryPayment.create(price: 0, user: payee)
      end

      @slack_bot.send(:send_checkout_message, format, grocery)

      @slack_bot.should have_received(:post_message).with(
        format,
        {
          title: grocery.name,
          contributors: ["#{payer.name} paid #{payer_payment.price.format}"].join(', '),
          recipients: users.map(&:name).join(', ')
        }
      )
    end
  end
end
