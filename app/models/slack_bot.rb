class SlackBot < ActiveRecord::Base
  belongs_to :user_group

  after_initialize :setup_client
  attr_accessor :client

  CONTRIBUTORS = 'contributors'.freeze
  RECIPIENTS = 'recipients'.freeze
  TITLE = 'title'.freeze

  INTERPOLATED_FIELDS = [
    CONTRIBUTORS,
    RECIPIENTS,
    TITLE
  ]

  def setup_client
    @client = Slack::Web::Client.new(token: api_token)
    @client.chat_postMessage(channel: '#general', text: 'hello world', as_user: true)
  end

  def send_checkout_message(grocery)
    field_data = { recipients: [], contributors: [] }
    grocery.payments.includes(:user).inject(field_data) do |field_values, payment|
      name = payment.user.name
      field_values.tap do |fv|
        fv[:contributors] << "#{name} paid #{payment.price.format}" if payment.price.nonzero?
        fv[:recipients] << name
      end
    end

    formatted_fields = {
      title: grocery.name,
      contributors: field_data[:contributors].join(', '),
      recipients: field_data[:recipients].join(', ')
    }

    @client.chat_postMessage(
      channel: '#general',
      as_user: true,
      text: INTERPOLATED_FIELDS.inject(format) do |message, field|
        message.gsub(/{#{field}}/, formatted_fields[field.to_sym])
      end
    )
  end
end
