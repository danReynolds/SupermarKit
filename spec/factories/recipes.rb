FactoryGirl.define do
  factory :recipe do
    sequence(:name) { |n| "Dan's homemade cooking #{n}" }
    sequence(:external_id) { |n| "recipe-#{n}" }
    url 'http://bestfood.com/thebestfood'

    trait(:with_items) do
      after(:create) do |instance|
        items = create_list :item, 3
        instance.items << items
      end
    end
  end
end
