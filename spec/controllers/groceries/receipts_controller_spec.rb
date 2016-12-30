require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe Groceries::ReceiptsController, type: :controller do
  include_context 'basic user'

  let(:grocery_id) { grocery.id }
  it_should_behave_like 'routes', show: { grocery_id: true }

  describe 'POST create' do
    let(:subject) { post :create, params: { grocery_id: grocery.id } }
    # Add additional text at the end of items to test the regex
    let(:processed_receipt) {
      [
        'BACON 54545845454 4.45',
        'LEMON 3.25',
        'BREAD 545458454544 3.20'
      ].join("\n")
    }

    before :each do
      engine = double('Tesseract::Engine', text_for: processed_receipt)
      allow(Tesseract::Engine).to receive(:new).and_return(engine)
      allow(Kernel).to receive(:open).and_return(double('file', path: nil))
    end

    context 'with matching item on list' do
      it 'should prioritize list items' do
        expected_matches = [{ name: 'Breed', price: 3.2 }].map(&:stringify_keys)
        Item.create(name: 'Bread')
        grocery.items << Item.create(name: 'Breed')

        subject
        matches = JSON.parse(response.body)

        expect(matches['total']).to eq 0
        expect(matches['list'].map! { |match| match.slice('name', 'price', 'new') }).to eq expected_matches
      end
    end

    context 'with duplicate matching items on list' do
      let(:processed_receipt) {
        [
          'BACON 54545845454 4.45',
          'BACON 54545845454 4.45',
          'LEMON 3.25',
          'BREAD 545458454544 3.20'
        ].join("\n")
      }

      it 'should aggregate the cost to a single item' do
        expected_matches = [{ name: 'Bacon', price: 8.90, new: true }].map(&:stringify_keys)
        Item.create(name: 'Bacon')

        subject
        matches = JSON.parse(response.body)

        expect(matches['total']).to eq 0
        expect(matches['list'].map! { |match| match.slice('name', 'price', 'new') }).to eq expected_matches
      end
    end

    context 'without matching item on list' do
      it 'should fallback to all items' do
        expected_matches = [{ name: 'Breed', price: 3.2, new: true }].map(&:stringify_keys)
        Item.create(name: 'Breed')

        subject
        matches = JSON.parse(response.body)

        expect(matches['total']).to eq 0
        expect(matches['list'].map! { |match| match.slice('name', 'price', 'new') }).to eq expected_matches
      end
    end

    context 'with a total keyword' do
      let(:processed_receipt) {
        [
          "#{Groceries::ReceiptsController::TOTAL_KEYWORDS.first.upcase} 44.45"
        ].join('\n')
      }

      it 'should prioritize matching the total keywords' do
        expected_matches = []
        Item.create(name: Groceries::ReceiptsController::TOTAL_KEYWORDS.first)

        subject
        matches = JSON.parse(response.body)

        expect(matches['total']).to eq 44.45
        expect(matches['list'].map! { |match| match.slice('name', 'price') }).to eq expected_matches
      end
    end

    context 'with multiple total keywords' do
      let(:processed_receipt) {
        [
          "#{Groceries::ReceiptsController::TOTAL_KEYWORDS.first.upcase} 4.45",
          "#{Groceries::ReceiptsController::TOTAL_KEYWORDS.last.upcase} 10.40"
        ].join("\n")
      }

      it 'should select the highest value total keyword' do
        expected_matches = []
        Item.create(name: Groceries::ReceiptsController::TOTAL_KEYWORDS.first)

        subject
        matches = JSON.parse(response.body)

        expect(matches['total']).to eq 10.40
        expect(matches['list'].map! { |match| match.slice('name', 'price') }).to eq expected_matches
      end
    end
  end

  describe 'POST confirm' do
    let(:subject) do
      patch :confirm, params: {
        grocery_id: grocery.id,
        grocery: grocery_params
      }
    end
    let(:grocery_params) do
      {
        matches: [
          {
            name: 'Bacon',
            price: 4.00
          }
        ]
      }
    end

    it "should return the uploader's id as the payer" do
      subject
      expect(JSON.parse(response.body)).to eq({
        uploader_id: controller.current_user.id
      }.with_indifferent_access)
    end

    context 'with an existing item' do
      let(:name) { 'Bacon' }
      let(:item) { create(:item, name: name) }
      context 'with the item on the grocery list' do
        it 'should set the price of the item to the match price' do
          grocery.items << item
          subject
          expect(item.grocery_item(grocery).price).to eq 4.00.to_money
        end
      end

      context 'with the item not on the grocery list' do
        it 'should add the item to the list with the correct price' do
          expect(grocery.items.find_by_id(item.id)).to eq nil
          subject
          expect(item.grocery_item(grocery).price).to eq 4.00.to_money
          expect(grocery.items.find_by_name(name)).to eq item
        end
      end
    end

    context 'without an existing item' do
      it 'should create the item and add it to the grocery list with the correct price' do
        name = 'Bacon'
        expect(Item.find_by_name(name)).to eq nil
        subject
        item = Item.find_by_name(name)
        expect(item.grocery_item(grocery).price).to eq 4.00.to_money
        expect(grocery.items.find_by_name(name)).to eq item
      end
    end
  end
end
