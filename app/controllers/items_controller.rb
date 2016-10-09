class ItemsController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :grocery
  load_and_authorize_resource :item, through: :grocery, shallow: true

  def index
    render json: {
      data: items_data
    }
  end

  def update
    grocery_item = @item.grocery_item(@grocery)
    previous_item_values = {
      price: grocery_item.price_or_estimated.format(symbol: false).to_f
    }

    if unit = groceries_items_params[:units]
      params[:item][:groceries_items_attributes][:units] = Unit.new(unit).units
    end

    @item.update!(item_params)
    grocery_item.reload
    render json: {
      data: {
        previous_item_values: previous_item_values,
        updated_item_values: {
          quantity: grocery_item.reload.quantity.to_f,
          units: grocery_item.units,
          display_name: grocery_item.display_name,
          price: grocery_item.price_or_estimated.format(symbol: false).to_f
        }
      }
    }
  end

  def auto_complete
    items = @grocery.user_group.privacy_items.select(:id, :description, :name)
      .with_name(params[:q]).order('LENGTH(items.name) ASC').limit(5)

    render json: {
      data: items.map do |item|
        {
          id: item.id,
          name: item.name,
          description: item.description
        }
      end
    }
  end

private
  def items_data
    @grocery.groceries_items.inject({ total: 0, items: [] }) do |acc, grocery_item|
      acc.tap do |a|
        a[:items] << format_item(grocery_item)
        a[:total] += grocery_item.price_or_estimated.to_f
      end
    end
  end

  def format_item(grocery_item)
    quantity = grocery_item.quantity
    {
      id: grocery_item.item.id,
      name: grocery_item.item.name,
      description: grocery_item.item.description.to_s,
      grocery_item_id: grocery_item.id,
      quantity: quantity == quantity.floor ? quantity.to_i : quantity.to_f,
      units: grocery_item.units,
      display_name: grocery_item.display_name,
      price: grocery_item.price_or_estimated.format(symbol: false).to_f,
      url: item_path(grocery_item.item.id),
      requester: grocery_item.requester_id
    }
  end

  def item_params
    params.require(:item).permit(
      :name,
      :description,
      groceries_items_attributes: [
        :price,
        :price_cents,
        :id,
        :quantity,
        :grocery_id,
        :units
      ]
    )
  end

  def groceries_items_params
    params.require(:item).require(:groceries_items_attributes).permit(
      :price,
      :price_cents,
      :id,
      :quantity,
      :grocery_id,
      :units
    )
  end
end
