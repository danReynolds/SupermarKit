FactoryGirl.define do
  factory :grocery do
    sequence(:name) { |g| "grocery#{g}"}

    trait(:with_items) do
      after(:create) do |instance|
        create_list :item, 3, groceries: [instance]
      end
    end
  end
end
