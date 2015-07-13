class ItemsController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :grocery
  load_and_authorize_resource :item, through: :grocery, shallow: true

	def index
		respond_to do |format|
			format.json do
		    items = @items.map do |item|
		      {
		      	id: item.id,
		      	name: item.name,
		      	description: item.description.to_s,
		      	quantity_id: item.groceries_items.find_by_grocery_id(@grocery.id).id,
		      	quantity: item.quantity(@grocery),
		      	price: item.price.dollars.to_s,
		      	price_formatted: item.price.format,
		      	total_price_formatted: item.total_price(@grocery).format,
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
					render nothing: true, status: :ok
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
		items = @grocery.user_group.privacy_items.with_name(params[:q]) - @grocery.items
		items = items.first(5).map do |item|
		  {
				id: item.id,
			 	name: item.name,
				description: item.description
			}
		end

		render json: {
			total_items: items.count,
			items: items
		}
	end

	def add
		items = params[:items][:ids].split(",").map do |id|
			Item.find_by_id(id) || Item.create(name: id, price_cents: 0)
		end

		@grocery.items << items
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
		params.require(:item).permit(:name, :description, :price, :price_cents, groceries_items_attributes: [:id, :quantity, :grocery_id])
	end
end
