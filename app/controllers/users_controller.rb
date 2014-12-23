class UsersController < ApplicationController
	skip_before_filter :require_login, only: [:index, :new, :create]
	
	def index
	end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
  	@user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_to user_groups_path, notice: "Hey Softie #{@user.name}"  
    else  
      render :new
    end
  end

  def auto_complete
    users = User.with_name(params[:q]).each do |user|
      {
        id: user.id,
        name: user.name
      }
    end

    render json: {
      total_users: users.count,
      users: users
    }
  end

private
	
	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end 
end
