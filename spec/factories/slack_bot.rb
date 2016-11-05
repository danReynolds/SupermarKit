FactoryGirl.define do
  factory :slack_bot do
  end

  trait :with_messages do
    after :create do
      create_list :slack_message, 1, slack_bot: instance
    end
  end
end
