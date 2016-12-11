class ItemsController < ApplicationController
  extend HappyPath
  include ActiveModelSerializers
  follow_happy_paths
  load_and_authorize_resource :grocery
  load_and_authorize_resource :item, through: :grocery, shallow: true

  def update
    grocery_item = @item.grocery_item(@grocery)
    @item.update!(item_params)
    render json: {
      grocery_item: SerializableResource.new(grocery_item).as_json,
      updated_grocery_item: SerializableResource.new(grocery_item.reload).as_json
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
    @grocery.groceries_items.includes(:item).inject({ total: 0, items: [] }) do |acc, grocery_item|
      acc.tap do |a|
        a[:items] << format_item(grocery_item)
        a[:total] += grocery_item.price_or_estimated.to_f
      end
    end
  end

  def format_item(grocery_item)
    item = grocery_item.item
    {
      id: item.id,
      name: item.name,
      description: item.description.to_s,
      grocery_item_id: grocery_item.id,
      quantity: grocery_item.quantity.to_f,
      units: grocery_item.units,
      display_name: grocery_item.display_name,
      price: grocery_item.price_or_estimated.format(symbol: false).to_f,
      url: item_path(item.id),
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
