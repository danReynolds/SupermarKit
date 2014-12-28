class GroceriesController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :user_group
  load_and_authorize_resource :grocery, through: :user_group, shallow: true

	def index
    respond_to do |format|
      format.json do
        groceries = @user_group.groceries.map do |grocery|
          [
            grocery.id,
            "<a href='/groceries/#{grocery.id}'>#{grocery.name}</a>".html_safe,
            grocery.description,
            grocery.items.count,
            grocery.updated_at.to_date
          ]
        end
        render json: { data: groceries }
      end
    end
	end
	
	def show
	end

	def new
  end

  def create
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

private

  def grocery_params
    params.require(:grocery).permit(:name, :description)
  end
end
