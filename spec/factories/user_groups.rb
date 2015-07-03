FactoryGirl.define do
  factory :user_group do
    sequence(:name) { |n| "softiehouse#{n}" }
    privacy "public"

    trait(:with_groceries) do
      after(:create) do |instance|
        create_list(:grocery, 2, :with_items, user_group: instance)
      end
    end

    trait(:with_empty_groceries) do
      after(:create) do |instance|
        create_list(:grocery, 2, user_group: instance)
      end
    end

    trait(:with_users) do
      after(:create) do |instance|
        users = create_list :user, 2
        instance.users << users
      end
    end

    trait(:with_finished_groceries) do
      after(:create) do |instance|
        create_list(:grocery, 2, user_group: instance, finished: true)
      end
    end
  end
end
