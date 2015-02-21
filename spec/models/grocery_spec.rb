require 'rails_helper'

RSpec.describe Grocery, type: :model do
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
