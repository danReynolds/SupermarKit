class GroceriesController < ApplicationController
	def index
	end
	
	def show
		@grocery = Grocery.find(params[:id])
	end

	def new
    @grocery = Grocery.new
	end

	def create
    @grocery = Grocery.create(grocery_params)
    @grocery.users << current_user

    if @grocery.save
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
		grocery = Grocery.find(params[:id])
		items = current_user.items.with_name(params[:q]) - grocery.items
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

	def add_items
		grocery = Grocery.find(params[:id])
		items = Item.find(params[:grocery][:name].split(",")[1..-1])
		grocery.items << items
		render json: { success: true }
	end

	def remove_item
		grocery = Grocery.find(params[:id])
		item = Item.find(params[:item_id])

		grocery.items.delete(item)

		render json: { success: true }
	end

	def items
    grocery = Grocery.find(params[:id])

    items = grocery.items.map do |item|
      info = [
        "<a src='/items/#{item.id}'>#{item.name}</a>".html_safe,
        item.description,
        item.updated_at.to_date,
        "<a class='remove' href='#'><i class='fa fa-remove'></i></a>".html_safe
      ]
      info.unshift(item.id) if params[:with_id]
      info
    end

    render json: { data: items }
  end

private

  def grocery_params
    params.require(:grocery).permit(:name, :description)
  end

end
