require 'rails_helper'

RSpec.describe UserGroupsUsers, type: :model do
  describe '#balance' do
    let(:user) { create(:user, :full_user) }
    let(:other_user) { create(:user) }
    let(:grocery) { user.groceries.last }

    context 'with only one kit member' do
      it 'should always have a zero balance' do
        GroceryPayment.create(grocery: grocery, user: user, price: 4)

        grocery.user_group.user_groups_users.each do |user_group_user|
          expect(user_group_user.balance).to eq 0.to_money
        end
      end
    end

    context 'with multiple kit members' do
      before :each do
        user.user_groups.first.users << other_user
      end

      context 'with user payments' do
        before :each do
          GroceryPayment.create(grocery: grocery, user: user, price: 4)
          GroceryPayment.create(grocery: grocery, user: other_user, price: 0)
        end

        context 'with payer payments' do
          it 'should have the payer at a more negative balance' do
            UserPayment.create(user_group: grocery.user_group, payer: user, payee: other_user, price: 2)
            balances = {}
            balances[user.id] = -4.to_money
            balances[other_user.id] = 4.to_money

            grocery.user_group.user_groups_users.each do |user_group_user|
              expect(user_group_user.balance).to eq balances[user_group_user.user_id]
            end
          end
        end

        context 'with payee repayment' do
          context 'with full repayment' do
            it 'should have users at a zero balance' do
              UserPayment.create(user_group: grocery.user_group, payer: other_user, payee: user, price: 1)
              binding.pry
              UserPayment.create(user_group: grocery.user_group, payer: other_user, payee: user, price: 1)

              grocery.user_group.user_groups_users.each do |user_group_user|
                expect(user_group_user.balance).to eq 0.to_money
              end
            end
          end

          context 'with ample repayment' do
            it 'it should have the payee at a negative balance' do
              UserPayment.create(user_group: grocery.user_group, payer: other_user, payee: user, price: 10)
              balances = {}
              balances[user.id] = 8.to_money
              balances[other_user.id] = -8.to_money

              grocery.user_group.user_groups_users.each do |user_group_user|
                expect(user_group_user.balance).to eq balances[user_group_user.user_id]
              end
            end
          end
        end
      end

      context 'without user payments' do
        context 'with each member contributing' do
          context 'with equal pay' do
            it 'should have users at a zero balance' do
              GroceryPayment.create(grocery: grocery, user: user, price: 4)
              GroceryPayment.create(grocery: grocery, user: other_user, price: 4)

              grocery.user_group.user_groups_users.each do |user_group_user|
                expect(user_group_user.balance).to eq 0.to_money
              end
            end
          end

          context 'with unequal pay' do
            it 'it should determine positive and negative balance' do
              GroceryPayment.create(grocery: grocery, user: user, price: 4)
              GroceryPayment.create(grocery: grocery, user: other_user, price: 2)

              balances = {}
              balances[user.id] = -1.to_money
              balances[other_user.id] = 1.to_money

              grocery.user_group.user_groups_users.each do |user_group_user|
                expect(user_group_user.balance).to eq balances[user_group_user.user_id]
              end
            end
          end
        end
      end
    end

    context 'with only some members contributing' do
      it 'should not change the balance of a non-contributor' do
        GroceryPayment.create(grocery: grocery, user: user, price: 4)

        grocery.user_group.user_groups_users.each do |user_group_user|
          expect(user_group_user.balance).to eq 0.to_money
        end
      end
    end

    context 'with multiple kits' do
      it 'should only include payments from the specified kit' do
        other_user_group = create(:user_group, :with_groceries)
        other_user_group.users << [user, other_user]

        GroceryPayment.create(grocery: other_user_group.groceries.last, user: other_user, price: 4)
        GroceryPayment.create(grocery: other_user_group.groceries.last, user: user, price: 0)
        GroceryPayment.create(grocery: grocery, user: user, price: 4)
        GroceryPayment.create(grocery: grocery, user: other_user, price: 0)

        balances = {}
        balances[user.id] = -2.to_money
        balances[other_user.id] = 2.to_money

        grocery.user_group.user_groups_users.each do |user_group_user|
          expect(user_group_user.balance).to eq balances[user_group_user.user_id]
        end
      end
    end
  end
end
