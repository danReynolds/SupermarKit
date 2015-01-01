FactoryGirl.define do
  factory :user do
    name  { |n| "Softie#{n}" }
    password "Soft"
    password_confirmation { password }
    sequence(:email) { "#{name}@test.com" }
  end
end
