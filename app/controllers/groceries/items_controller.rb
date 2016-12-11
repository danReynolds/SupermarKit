class Groceries::ItemsController < ApplicationController
  include SplitController
  include ActiveModelSerializers
  initialize_split_controller :grocery

  def show
    render json: @grocery.items, scope_name: :grocery, scope: @grocery, with_link: true
  end

  def update
    items_params = grocery_items_params[:items]
    existing_groceries_items = @grocery.groceries_items
    existing_items = Item.accessible_by(current_ability)

    updated_groceries_items = items_params.map do |item_params|
      create_or_update_grocery_item(
        existing_groceries_items,
        existing_items,
        item_params
      )
    end
    GroceriesItems.delete(existing_groceries_items - updated_groceries_items)

    head :ok
  end

  private

  def create_or_update_grocery_item(groceries_items, items, item_params)
    groceries_items.find_or_create_by(
      grocery: @grocery,
      item: items.find_or_create_by(name: item_params[:name])
    ).tap do |grocery_item|
      grocery_item.update!(
        item_params.slice(:quantity, :price, :units).merge({
          requester_id: grocery_item.requester_id || current_user.id
        }).to_h
      )
    end
  end

  def grocery_items_params
    params.require(:grocery)
      .permit(items: [:id, :quantity, :price, :units, :name])
  end
end
