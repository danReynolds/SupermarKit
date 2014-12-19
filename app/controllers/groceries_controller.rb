class GroceriesController < ApplicationController
	def index
	end
	
	def show
	end

	def new
	end

	def create
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
end
