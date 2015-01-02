FactoryGirl.define do
  factory :user_group do
    sequence(:name) { |n| "softiehouse#{n}" }

    trait(:with_groceries) do
      after(:create) do |instance, evaluator|
        create_list(:grocery, 2, user_group: instance)
      end
    end
  end
end
