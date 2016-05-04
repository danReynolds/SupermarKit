FactoryGirl.define do
  factory :item do
    sequence(:name) { |n| "Item#{n}" }
  end
end
