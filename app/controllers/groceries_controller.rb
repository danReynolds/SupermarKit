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
		raise
	end

	def add_items
		grocery = Grocery.find(params[:id])
		items = Item.find(params[:grocery][:name][1..-1])
		grocery.items << items
		render json: { success: true }
	end
end
