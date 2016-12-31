require 'rails_helper'
require 'support/basic_user'
require 'support/routes'

describe Groceries::RecipesController, type: :controller do
  include_context 'basic user'

  describe 'PATCH update' do
    let(:recipe) { create(:recipe, :with_items) }
    let(:subject) { patch :update, params: { grocery_id: grocery.id, grocery: grocery_params } }
    let(:grocery_params) {
      {
        recipes: [
          {
            external_id: recipe.external_id
          }
        ]
      }
    }

    it 'should remove old recipe items and add new ones' do
      other_recipe = create(:recipe, :with_items)
      grocery.recipes << other_recipe
      grocery.items << other_recipe.items
      items = Item.find(grocery.item_ids)
      subject
      expect(grocery.reload.items).to match_array(
        items + recipe.items - other_recipe.items
      )
    end

    it 'should add the recipe to the grocery' do
      subject
      expect(grocery.reload.recipes.first).to eq recipe
    end

    context 'adding existing recipe' do
      it "should update the grocery's items to include the recipe items" do
        items = Item.find(grocery.item_ids)
        subject
        expect(grocery.reload.items).to match_array(items + recipe.items)
      end

      it 'should use the existing recipe' do
        recipe = create(:recipe)
        grocery_params[:recipes] = [
          {
            external_id: recipe.external_id
          }
        ]
        expect { subject }.to_not change(Recipe, :count)
      end
    end

    context 'adding a new recipe' do
      before(:each) do
        grocery_params[:recipes] << {
          name: 'new recipe',
          url: 'http://newrecipe.com',
          external_id: 'recipe-external-id',
          ingredients: [
            'Ground pepper',
            'Potato',
            'tomatoes'
          ],
          ingredientDescriptions: [
            '2.5 cups of fresh ground peppers',
            '4 potatoes',
            'tomatoes'
          ]
        }
      end

      it 'should format the item names' do
        subject
        formatted_item = grocery.reload.recipes.last.items.find_by_name('Tomato')
        expect(formatted_item).not_to eq nil
      end

      it 'should not create an item if one by that name already exists' do
        grocery_params[:recipes].last[:ingredients].each do |item_name|
          create(:item, name: item_name)
        end
        expect { subject }.to_not change(Item, :count)
      end

      it 'should not add an item to a list if it is already on the list' do
        grocery_params[:recipes].last[:ingredients].each do |item_name|
          grocery.items << create(:item, name: item_name)
        end
        expect { subject }.to_not change(Item, :count)
      end

      it 'should match items to ingredient lines including units and quantity' do
        item_results = [
          {
            name: 'Ground pepper',
            quantity: 2.5,
            units: 'cup'
          },
          {
            name: 'Potato',
            quantity: 4
          },
          {
            name: 'Tomato',
            quantity: 1
          }
        ]
        subject
        Recipe.last.items.each_with_index do |item, index|
          grocery_item = item.grocery_item(grocery)
          expect(item.name).to eq item_results[index][:name]
          expect(grocery_item.quantity).to eq item_results[index][:quantity]
          expect(grocery_item.units).to eq item_results[index][:units]
        end
      end

      it 'should recover from unparseable ingredient amounts' do
        grocery_params[:recipes].last[:ingredientDescriptions][0] = 'ground peppers'
        item_results = [
          {
            name: 'Ground pepper',
            quantity: 1
          },
          {
            name: 'Potato',
            quantity: 4
          },
          {
            name: 'Tomato',
            quantity: 1
          }
        ]
        subject
        Recipe.last.items.each_with_index do |item, index|
          grocery_item = item.grocery_item(grocery)
          expect(item.name).to eq item_results[index][:name]
          expect(grocery_item.quantity).to eq item_results[index][:quantity]
          expect(grocery_item.units).to eq item_results[index][:units]
        end
      end

      it 'should handle ingredient lines with containers' do
        grocery_params[:recipes]
          .last[:ingredientDescriptions][0] = '1 15.5 oz can of ground pepper'
        item_results = [
          {
            name: 'Ground pepper',
            quantity: 15.5,
            units: 'ounce'
          },
          {
            name: 'Potato',
            quantity: 4
          },
          {
            name: 'Tomato',
            quantity: 1
          }
        ]
        subject
        Recipe.last.items.each_with_index do |item, index|
          grocery_item = item.grocery_item(grocery)
          expect(item.name).to eq item_results[index][:name]
          expect(grocery_item.quantity).to eq item_results[index][:quantity]
          expect(grocery_item.units).to eq item_results[index][:units]
        end
      end

      it 'should add the new recipe to the grocery' do
        expect { subject }.to change(Recipe, :count).by(1)
        expect(grocery.reload.recipes.last).to eq Recipe.last
      end

      it "should create the new recipe's items" do
        expect { subject }.to change(Item, :count).by(3)
        expect(grocery.reload.recipes.last.items).to eq Item.all.last(3)
      end
    end
  end
end
