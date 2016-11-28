class SlackMessage < ApplicationRecord
  SEND_CHECKOUT_MESSAGE = 'send_checkout_message'.freeze
  SEND_GROCERY_RECEIPT = 'send_grocery_receipt'.freeze

  MESSAGE_TYPES = [
    SEND_CHECKOUT_MESSAGE,
    SEND_GROCERY_RECEIPT
  ]

  belongs_to :slack_bot
  validates :message_type, uniqueness: { scope: :slack_bot_id }
  validates :message_type, inclusion: { in: MESSAGE_TYPES }
end
