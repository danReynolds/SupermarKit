class GroceriesController < ApplicationController
	def index
    user_group = UserGroup.find(params[:user_group_id])

    respond_to do |format|
      format.json do
        groceries = user_group.groceries.map do |grocery|
          [
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
		@grocery = Grocery.find(params[:id])
	end

	def new
    @user_group = UserGroup.find(params[:user_group_id])
    @grocery = Grocery.new
  end

  def create
    params[:grocery].merge!(user_group_id: params[:user_group_id])
    @grocery = Grocery.new(grocery_params)

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
    params.require(:grocery).permit(:name, :description, :user_group_id)
  end
end
