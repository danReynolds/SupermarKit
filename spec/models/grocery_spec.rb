require 'rails_helper'

RSpec.describe Grocery, type: :model do
  describe '#total_price_or_estimated' do
    it 'prioritizes grocery pricing' do
      grocery = create(:grocery)
      item1 = create(:item)
      item2 = create(:item)
      grocery.items << [item1, item2]
      item1.grocery_item(grocery).update_attribute(:price_cents, 500)
      item1.grocery_item(grocery).update_attribute(:quantity, 2)
      item2.grocery_item(grocery).update_attribute(:price_cents, 724)

      expect(grocery.total_price_or_estimated.to_f).to eq 12.24
    end

    it 'falls back to estimated pricing' do
      grocery = create(:grocery)
      other_grocery = create(:grocery)
      item1 = create(:item)
      item2 = create(:item)
      grocery.items << [item1, item2]
      other_grocery.items << [item1]
      item1.grocery_item(other_grocery).update_attribute(:price_cents, 500)
      item1.grocery_item(grocery).update_attribute(:quantity, 2)
      item2.grocery_item(grocery).update_attribute(:price_cents, 724)

      expect(grocery.total_price_or_estimated.to_f).to eq 12.24
    end
  end

  describe '#finished?' do
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
