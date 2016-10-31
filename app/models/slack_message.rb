class SlackMessage < ActiveRecord::Base
  MESSAGE_TYPES = {
    send_checkout_message: {
      id: 'send-checkout-message',
      name: 'Send Checkout Message',
      fields: [:contributors, :recipients, :title],
      description: 'Message sent on checkout with payment information.',
      exampleInput: 'Hello, for {title} {contributors} for {recipients}.',
      exampleFields: {
        contributors: 'Luke paid $45',
        recipients: 'Vader',
        title: 'The new death star',
      }
    }
  }
  belongs_to :slack_bot
  validates :message_type, inclusion: { in: MESSAGE_TYPES.keys.map(&:to_s) }
  validates :message_type, uniqueness: { scope: :slack_bot_id }
end
