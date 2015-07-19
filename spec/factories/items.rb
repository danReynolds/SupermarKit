FactoryGirl.define do
  factory :item do
    sequence(:name) { |n| "item#{n}" }
  end
end
