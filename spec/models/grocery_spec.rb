require 'rails_helper'

RSpec.describe Grocery, type: :model do
  it 'totals items' do
    grocery = create(:grocery)
    item1 = create(:item, grocery_ids: grocery.id, price_cents: 500)
    item2 = create(:item, grocery_ids: grocery.id, price_cents: 724)

    expect(grocery.total).to eq 12.24
  end
end
