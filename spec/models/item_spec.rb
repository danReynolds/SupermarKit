require 'rails_helper'

RSpec.describe Item, type: :model do
  it 'scopes by name' do
    item1 = create(:item, name: "Softie Jam")
    item2 = create(:item, name: "Softie Marmelade")

    search = Item.with_name('Jam')
    expect(search).to eq [item1]
  end
end
