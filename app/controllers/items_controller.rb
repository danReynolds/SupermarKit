class ItemsController < ApplicationController
	extend HappyPath
  follow_happy_paths
  
	def index
		grocery = Grocery.find(params[:grocery_id])

		respond_to do |format|
			format.json do
		    items = grocery.items.map do |item|
		      info = [
		      	item.id,
		        "<a href='/items/#{item.id}'>#{item.name}</a>".html_safe,
		        item.description,
		        item.price.format,
		        item.updated_at.to_date,
		        "<a class='remove' href='#'><i class='fa fa-remove'></i></a>".html_safe
		      ]
		    end
    		render json: { data: items }
		  end
    end
	end
	
	def show
		@item = Item.find(params[:id])
		@kit = @item.groceries.first.user_group
	end

	def new
		@grocery = Grocery.find(params[:grocery_id])
		@item = Item.new
	end

	def create
		@item = Item.new(item_params)
		@grocery = Grocery.find(params[:grocery_id])

		if @item.save
			@item.groceries << @grocery
			redirect_to @grocery
		else
			render action: :new
		end
	end

	def edit
	end

	def update
	end

	def auto_complete
		grocery = Grocery.find(params[:grocery_id])
		items = grocery.user_group.items.with_name(params[:q]) - grocery.items
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
		grocery = Grocery.find(params[:grocery_id])
		items = Item.find(params[:items][:ids].split(","))
		grocery.items << items
		render json: { success: true }
	end

	def remove
		grocery = Grocery.find(params[:grocery_id])
		item = Item.find(params[:id])

		grocery.items.delete(item)

		render json: { success: true }
	end

private
	def item_params
		params.require(:item).permit(:name, :description, :price)
	end
end
