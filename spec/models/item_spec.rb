require 'rails_helper'

describe Item, type: :model do
  describe 'name scoping' do
    it 'should scope by name' do
      item1 = create(:item, name: "Softie Jam")
      item2 = create(:item, name: "Softie Marmelade")

      search = Item.with_name('Jam')
      expect(search).to eq [item1]
    end
  end

  describe 'calculating item cost' do
    before :each do
      @item = create(:item, price_cents: 100)
      @grocery = create(:grocery)
      @grocery.items << @item
      @item.groceries_items.find_by_grocery_id(@grocery.id).update_attribute(:quantity, 2)
    end

    it 'returns the proper quantity' do
      expect(@item.quantity(@grocery)).to eq 2
    end

    it 'calculates total based on quantity' do
      expect(@item.total_price(@grocery)).to eq 2.00
    end
  end
end
