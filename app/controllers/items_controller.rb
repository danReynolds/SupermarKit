class ItemsController < ApplicationController
	extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :grocery
  load_and_authorize_resource :item, through: :grocery, shallow: true

	def index
		respond_to do |format|
			format.json do
		    items = @items.map do |item|
		      info = [
		      	item.id,
		        "<a href='#' id='well' class='editable' name='name' data-type='text' data-pk='{ item_id: #{item.id} }' data-url='#{item_path(item.id)}'>#{item.name}</a>".html_safe,
		        "<a href='#' class='editable' name='description' data-type='text' data-pk='{ item_id: #{item.id} }' data-url='#{item_path(item.id)}'>#{item.description}</a>".html_safe,
		        "<a href='#' class='editable' name='groceries_items_attributes' data-type='text' data-pk='{ item_id: #{item.id}, groceries_items_id: #{item.groceries_items.find_by_grocery_id(@grocery.id).id} }' data-url='#{item_path(item.id)}'>#{item.quantity(@grocery)}</a>".html_safe,
		        "<a href='#' class='editable' name='price' data-value='#{item.price}' data-type='text' data-pk='{ item_id: #{item.id} }' data-url='#{item_path(item.id)}'>#{item.price.format}</a>".html_safe,
		        item.total_price(@grocery).format,
		        "<a class='remove' href='#'><i class='fa fa-remove'></i></a>".html_safe
		      ]
		    end
    		render json: { data: items }
		  end
    end
	end

	def show
		@user_group = @item.groceries.first.user_group
	end

	def new
		@groceries_items = @item.groceries_items.build
	end

	def create
		@item = Item.new(item_params)
		@item.name.capitalize!

		if @item.save
			redirect_to @grocery
		else
			render action: :new
		end
	end

	def edit
		@user_group = @item.groceries.first.user_group
	end

	def update
		respond_to do |format|
			format.json do
				if @item.update_attributes(item_params)
					render json: { status: :ok }
				else
					render json: { status: :internal_server_error }
				end
			end

			format.html do
				raise
				if @item.update_attributes(item_params)
					redirect_to @item.groceries.first.user_group
				else
					render :edit
				end
			end
		end
	end

	def auto_complete
		items = @grocery.user_group.items.with_name(params[:q]) - @grocery.items
		items.map do |item|
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
		render json: { success: true }
	end

	def remove
		# the grocery is already loaded because grocery_id was passed with the request
		# cancancan picks up on the grocery_id being passed when using load_resource
		@grocery.items.delete(@item)
		render json: { success: true }
	end

private
	def item_params
		params.require(:item).permit(:name, :description, :price, :price_cents, groceries_items_attributes: [:id, :quantity, :grocery_id])
	end
end
