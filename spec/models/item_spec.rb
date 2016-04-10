require 'rails_helper'

describe Item, type: :model do
  describe '#with_name' do
    it 'should find matching query' do
      item = create(:item, name: 'Softie Jam')
      search = Item.with_name('Jam')
      expect(search).to eq [item]
    end

    it 'should not find unmatched query' do
      search = Item.with_name('Spam')
      expect(search).to eq []
    end
  end
end
