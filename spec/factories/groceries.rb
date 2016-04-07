FactoryGirl.define do
  factory :grocery do
    sequence(:name) { |g| "grocery#{g}"}

    trait(:with_items) do
      after(:create) do |instance|
        items = create_list :item, 3
        instance.items << items
        instance.items.each do |item|
          item.grocery_item(instance).update_attribute(:price_cents, (100..500).to_a.sample)
        end
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
