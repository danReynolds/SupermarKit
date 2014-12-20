class UsersController < ApplicationController
	skip_before_filter :require_login, only: [:index, :new, :create]
	
	def index
	end

  def show
    @user = User.find(params[:id])
    @active_grocery = Grocery.last
  end

  def new
    @user = User.new
  end

  def create
  	@user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_to @user, notice: "Hey Softie #{@user.name}"  
    else  
      render :new
    end
  end

  def groceries
    user = User.find(params[:id])

    groceries = user.groceries.map do |grocery|
      [
        "<a src='/groceries/#{grocery.id}''>#{grocery.name}</a>".html_safe,
        grocery.description,
        grocery.items.count,
        grocery.updated_at.to_date
      ]
    end
    render json: { data: groceries }
  end

  def items
    user = User.find(params[:id])
    grocery = Grocery.find(params[:grocery_id])

    items = grocery.items.map do |item|
      [
        "<a src='/items/#{item.id}''>#{item.name}</a>".html_safe,
        item.description,
        item.updated_at.to_date
      ]
    end

    render json: { data: items }
  end

private
	
	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end 
end
