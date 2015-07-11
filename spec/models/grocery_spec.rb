require 'rails_helper'

RSpec.describe Grocery, type: :model do
  describe 'calculating grocery cost' do
    it 'totals items' do
      grocery = create(:grocery)
      item1 = create(:item, price_cents: 500)
      item2 = create(:item, price_cents: 724)
      grocery.items << [item1, item2]

      expect(grocery.total).to eq 12.24
    end

    it 'factors in quantity' do
      item = create(:item, price_cents: 500)
      grocery = create(:grocery)

      grocery.items << item
      item.groceries_items.find_by_grocery_id(grocery.id).update_attribute(:quantity, 2)
      expect(grocery.total).to eq 10.00
    end
  end

  describe 'state of grocery' do
    context 'when the grocery is finished' do
      let(:grocery) { create(:grocery, finished_at: DateTime.now) }
      it 'should confirm that it is finished' do
        expect(grocery.finished?).to eq true
      end
    end

    context 'when the grocery is not finished' do
      let(:grocery) { create(:grocery) }
      it 'should confirm that it is not finished' do
        expect(grocery.finished?).to eq false
      end
    end
  end
end
