class SlackBot < ActiveRecord::Base
  belongs_to :user_group
  has_many :slack_messages

  after_initialize :setup_client
  attr_accessor :client

  CHANNEL = "general".freeze

  def setup_client
    @client = Slack::Web::Client.new(token: api_token)
  end

  def send_message(type, *args)
    message = slack_messages.find_by_message_type(type)
    self.send(type, message, *args)
  end

  private

  def send_checkout_message(message, grocery)
    field_data = { recipients: [], contributors: [] }
    grocery.payments.includes(:user).inject(field_data) do |field_values, payment|
      name = payment.user.name
      field_values.tap do |fv|
        if payment.price.nonzero?
          fv[:contributors] << "#{name} paid #{payment.price.format}"
        end
        fv[:recipients] << name
      end
    end

    formatted_fields = {
      title: grocery.name,
      contributors: field_data[:contributors].join(', '),
      recipients: field_data[:recipients].join(', ')
    }

    @client.chat_postMessage(
      channel: "##{CHANNEL}",
      as_user: true,
      text: formatted_fields.keys.inject(message.format) do |format, field|
        format.gsub(/{#{field}}/, formatted_fields[field.to_sym])
      end
    )
  end
end
