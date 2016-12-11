class Groceries::ItemsController < ApplicationController
  include SplitController
  include ActiveModelSerializers
  initialize_split_controller :grocery

  def show
    render json: @grocery.items, scope_name: :grocery, scope: @grocery, with_link: true
  end

  def update
    items = @grocery.items
    existing_items = Item.accessible_by(current_ability)
    updated_items = grocery_items_params[:items].map do |item_params|
      item_params[:groceries_items_attributes][:requester_id] ||= current_user.id
      existing_items.find_or_create_by(
        name: Item.format_name(item_params[:name])
      ).tap do |item|
        item.update!(item_params)
      end
    end
    @grocery.items.delete(items - updated_items)
    head :ok
  end

  private

  def grocery_items_params
    params.require(:grocery).permit(
      items: [
        :id,
        :name,
        groceries_items_attributes: [
          :id,
          :quantity,
          :price,
          :units,
          :requester_id,
          :grocery_id
        ]
      ]
    )
  end
end
