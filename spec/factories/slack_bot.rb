FactoryGirl.define do
  factory :slack_bot do
    api_token 'test token'
  end

  trait :with_messages do
    after :create do |instance|
      CONFIGURABLES[:slack_messages].each do |message|
        create(
          :slack_message,
          slack_bot: instance,
          format: message[:format],
          message_type: message[:id],
          enabled: true,
        )
      end
    end
  end
end
