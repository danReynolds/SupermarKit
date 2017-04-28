class ItemsController < ApplicationController
  extend HappyPath
  include ActiveModelSerializers
  follow_happy_paths
  load_and_authorize_resource :grocery
  load_and_authorize_resource :item, through: :grocery, shallow: true

  def update
    grocery_item = @item.grocery_item(@grocery)
    if @item.update(item_params)
      render json: {
        grocery_item: SerializableResource.new(grocery_item).as_json,
        updated_grocery_item: SerializableResource.new(grocery_item.reload).as_json
      }
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def auto_complete
    items = @grocery.user_group.privacy_items.select(:id, :description, :name)
                    .with_name(params[:q]).order('LENGTH(items.name) ASC')
                    .limit(5)

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
