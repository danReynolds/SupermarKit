class ItemsController < ApplicationController
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

	def quick_add
		Grocery.first.items << Item.find(params[:item][:id])
	end

	def auto_complete
		items = Item.search(params[:query]).map do |a|
			{
				value: a.name,
				id: a.id
			}
		end
		render json: items.to_json
	end
end