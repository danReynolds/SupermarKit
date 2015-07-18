FactoryGirl.define do
  factory :grocery_store do
    sequence(:name) { |n| "Convenience Foods #{n}" }
    lat 43.12345
    lng -80.54321
  end

  trait(:with_place_id) do
    sequence(:place_id) { |n| "testplaceid#{n}" }
  end
end
