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

private
	
	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end 
end
