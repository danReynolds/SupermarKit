require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe Groceries::ReceiptsController, type: :controller do
  include_context 'basic user'

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
      file = double('file')
      allow(file).to receive(:path) {}
      allow_any_instance_of(Groceries::ReceiptsController).to receive(:open).and_return(file)
      allow_any_instance_of(Tesseract::Engine).to receive(:text_for).and_return(processed_receipt)
    end

    context 'with matching item on list' do
      it 'should prioritize list items' do
        expected_matches = [{ name: 'Breed', price: 3.2 }].map(&:stringify_keys)
        Item.create(name: 'Bread')
        grocery.items << Item.create(name: 'Breed')

        subject
        results = JSON.parse(response.body)

        expect(results['total']).to eq 0
        expect(results['matches'].map! { |match| match.slice('name', 'price', 'new') }).to eq expected_matches
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
        results = JSON.parse(response.body)

        expect(results['total']).to eq 0
        expect(results['matches'].map! { |match| match.slice('name', 'price', 'new') }).to eq expected_matches
      end
    end

    context 'without matching item on list' do
      it 'should fallback to all items' do
        expected_matches = [{ name: 'Breed', price: 3.2, new: true }].map(&:stringify_keys)
        Item.create(name: 'Breed')

        subject
        results = JSON.parse(response.body)

        expect(results['total']).to eq 0
        expect(results['matches'].map! { |match| match.slice('name', 'price', 'new') }).to eq expected_matches
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
        results = JSON.parse(response.body)

        expect(results['total']).to eq 44.45
        expect(results['matches'].map! { |match| match.slice('name', 'price') }).to eq expected_matches
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
        results = JSON.parse(response.body)

        expect(results['total']).to eq 10.40
        expect(results['matches'].map! { |match| match.slice('name', 'price') }).to eq expected_matches
      end
    end
  end
end
