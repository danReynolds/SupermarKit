FactoryGirl.define do
  factory :item do
    price_cents 0
    sequence(:name) { |n| "Item#{n}" }
  end
end
