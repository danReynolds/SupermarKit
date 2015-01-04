FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "Softie#{n}" }
    password 'Soft'
    password_confirmation { password }
    email { "#{name}@test.com" }

    trait :as_admin do
      after(:create) do |instance|
        instance.update_attribute(:roles, [:admin])
      end
    end
    
    trait :full_user do
      after(:create) do |instance|
        group = create(:user_group, users: [instance])
        create_list :grocery, 2, :with_items, user_group: group
      end
    end
  end
end
