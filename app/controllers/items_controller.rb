class ItemsController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :grocery
  load_and_authorize_resource :item, through: :grocery, shallow: true

  def index
    respond_to do |format|
      format.json do
        items = @items.select(:id, :name, :description).map do |item|
          grocery_item = GroceriesItems.find_by_item_id_and_grocery_id(item.id, @grocery.id)
          {
            id: item.id,
            name: item.name,
            description: item.description.to_s,
            grocery_item_id: grocery_item.id,
            quantity: grocery_item.quantity,
            price: grocery_item.price.dollars.to_s,
            price_formatted: grocery_item.price.format,
            total_price_formatted: grocery_item.total_price.format,
            path: item_path(item.id)
          }
        end
        render json: { data: items }
      end
    end
  end

  def show
    @user_group = @item.groceries.first.user_group
  end

  def new
    @groceries_items = @item.groceries_items.new
  end

  def create
    @item = Item.new(item_params)
    @item.name.capitalize!

    if @item.save
      redirect_to @grocery
    else
      render action: :new, alert: 'Unable to create new item.'
    end
  end

  def edit
    @user_group = @item.groceries.first.user_group
  end

  def update
    respond_to do |format|
      format.json do
        if @item.update_attributes(item_params)
          render json: {}, status: :ok
        else
          render nothing: true, status: :internal_server_error
        end
      end

      format.html do
        if @item.update_attributes(item_params)
          redirect_to @item.groceries.first.user_group
        else
          render :edit
        end
      end
    end
  end

  def auto_complete
    items = @grocery.user_group.privacy_items.select(:id, :description, :name)
                    .with_name(params[:q])
                    .where.not(id: @grocery.item_ids).limit(5)
    items.map do |item|
      {
        id: item.id,
        name: item.name,
        description: item.description
      }
    end

    render json: {
      total_items: items.length,
      items: items
    }
  end

  def add
    # Id is either an id of a known item or a name for a new one
    params[:items][:ids].split(',').each do |id|
      item = Item.find_by_id(id) || Item.create(name: id)

      @grocery.items << item
      groceries_item = item.grocery_item(@grocery)
      groceries_item.update_attributes(price_cents: groceries_item.localized_price)
    end

    render nothing: true, status: :ok
  end

  def remove
    # the grocery is already loaded because grocery_id was passed with the request
    # canard picks up on the grocery_id being passed when using load_resource
    @grocery.items.delete(@item)
    render nothing: true, status: :ok
  end

private
  def item_params
    params.require(:item).permit(
      :name,
      :description,
      groceries_items_attributes:
        [
          :price,
          :price_cents,
          :id, :quantity,
          :grocery_id
        ]
    )
  end
end
