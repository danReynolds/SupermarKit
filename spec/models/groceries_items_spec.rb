require 'rails_helper'

RSpec.describe GroceriesItems, type: :model do
  describe '#estimated_price' do
    context 'with units and quantity' do
      let(:item) { create(:item) }
      let(:grocery) { create(:grocery, items: [item]) }
      let(:grocery_item) { item.grocery_item(grocery) }
      let(:groceries) { create_list :grocery, 3, items: [item] }
      before :each do
        grocery_item.update(quantity: 300, units: 'gram')
        item.grocery_item(groceries[0]).update(price_cents: 200, quantity: 50, units: 'gram')
        item.grocery_item(groceries[1]).update(price_cents: 300, quantity: 100_000, units: 'mgram')
        item.grocery_item(groceries[2]).update(price_cents: 600, quantity: 200_000, units: 'mgram')
      end

      it 'should determine the price mode using equivalent units' do
        expect(grocery_item.estimated_price).to eq 9.to_money
      end
    end

    context 'without units and quantity' do
      let(:item) { create(:item) }
      let(:grocery) { create(:grocery, items: [item], grocery_store: current_store) }
      let(:grocery_item) { item.grocery_item(grocery) }
      let(:store_name) { 'Safeway' }
      let(:nearby_store_name) { 'Safeway' }
      let(:current_store) { create(:grocery_store, lat: 43, lng: -80, name: store_name) }
      let(:nearby_store) { create(:grocery_store, lat: 44, lng: -80, name: nearby_store_name) }
      let(:other_nearby_store) { create(:grocery_store, lat: 44, lng: -80, name: nearby_store_name) }

      before(:each) do
        groceries = create_list :grocery, 3, items: [item], grocery_store: nearby_store
        item.grocery_item(groceries[0]).update_attribute(:price_cents, 300)
        item.grocery_item(groceries[1]).update_attribute(:price_cents, 500)
        item.grocery_item(groceries[2]).update_attribute(:price_cents, 500)

        groceries = create_list :grocery, 3, items: [item], grocery_store: other_nearby_store
        item.grocery_item(groceries[0]).update_attribute(:price_cents, 500)
        item.grocery_item(groceries[1]).update_attribute(:price_cents, 300)
        item.grocery_item(groceries[2]).update_attribute(:price_cents, 500)

        other_groceries = create_list :grocery, 10, items: [item]
        other_groceries.each do |grocery|
          item.grocery_item(grocery).update_attribute(:price_cents, 50)
        end
      end

      context 'with a store' do
        context 'with nearby stores' do
          context 'with the same name' do
            it 'should assign the most common price from the nearby stores' do
              expect(grocery_item.estimated_price.fractional).to eq 500
            end

            it 'should fallback on the general most common price of outside closeness threshold' do
              create_list :grocery_store, 9, lat: 43, lng: -80, name: 'Safeway'
              expect(grocery_item.estimated_price.fractional).to eq 50
            end
          end

          context 'without the same name' do
            let(:nearby_store_name) { 'Sobeys' }
            it 'should fallback on the general most common price' do
              expect(grocery_item.estimated_price.fractional).to eq 50
            end
          end
        end

        context 'without a nearby store' do
          let(:nearby_store) { nil }
          let(:other_nearby_store) { nil }
          it 'should fallback on the general most common price' do
            expect(grocery_item.estimated_price.fractional).to eq 50
          end
        end
      end
    end
  end

  describe '#price_or_estimated' do
    let(:item) { create(:item) }
    let(:grocery) { create(:grocery, items: [item]) }
    let(:grocery_item) { item.grocery_item(grocery) }

    context 'with a price' do
      it 'should return the price' do
        grocery_item.update_attribute(:price_cents, 500)
        expect(grocery_item.price_or_estimated.fractional).to eq 500
      end
    end

    context 'without a price' do
      it 'should return the estimated price' do
        other_grocery = create(:grocery, items: [item])
        item.grocery_item(other_grocery).update_attribute(:price_cents, 500)
        expect(grocery_item.price_or_estimated.fractional).to eq 500
      end
    end
  end

  describe '#display_name' do
    let(:item) { create(:item, name: 'Bacon') }
    let(:grocery) { create(:grocery, items: [item]) }
    let(:grocery_item) { item.grocery_item(grocery) }

    context 'whole number' do
      context 'with units' do
        before :each do
          grocery_item.update_attribute(:units, 'gram')
        end

        context 'without pluralization' do
          it 'should display a singular whole number' do
            expect(grocery_item.display_name).to eq 'one gram of Bacon'
          end
        end

        context 'with pluralization' do
          it 'should display a plural whole number' do
            grocery_item.update_attribute(:quantity, 100)
            expect(grocery_item.display_name).to eq 'one hundred grams of Bacon'
          end
        end
      end

      context 'without units' do
        context 'without pluralization' do
          it 'should display a singular whole number' do
            expect(grocery_item.display_name).to eq 'one Bacon'
          end
        end

        context 'with pluralization' do
          it 'should display a plural whole number' do
            grocery_item.update_attribute(:quantity, 100)
            expect(grocery_item.display_name).to eq 'one hundred Bacons'
          end
        end
      end
    end

    context 'fractional number' do
      before :each do
        grocery_item.update_attribute(:quantity, 0.5)
      end

      context 'with units' do
        before :each do
          grocery_item.update_attribute(:units, 'cup')
        end
        it 'should display a singular fractional number' do
          expect(grocery_item.display_name).to eq 'a half cup of Bacon'
        end
      end

      context 'without units' do
        it 'should display a singular fractional number' do
          expect(grocery_item.display_name).to eq 'a half Bacon'
        end
      end
    end

    context 'mixed number' do
      before :each do
        grocery_item.update_attribute(:quantity, 1.5)
      end

      context 'with units' do
        it 'should display a plural mixed number' do
          grocery_item.update_attribute(:units, 'cup')
          expect(grocery_item.display_name).to eq 'one and a half cups of Bacon'
        end
      end

      context 'without units' do
        it 'should display a plural mixed number' do
          expect(grocery_item.display_name).to eq 'one and a half Bacons'
        end
      end
    end
  end
end
