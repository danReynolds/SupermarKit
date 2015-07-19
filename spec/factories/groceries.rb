FactoryGirl.define do
  factory :grocery do
    sequence(:name) { |g| "grocery#{g}"}

    trait(:with_items) do
      after(:create) do |instance|
        items = create_list :item, 3
        instance.items << items
      end
    end

    trait(:with_store) do
      after(:create) do |instance|
        store = create(:grocery_store)
        instance.update_attribute(:grocery_store, store)
      end
    end
  end
end
