class UsersController < ApplicationController
  skip_before_filter :require_login, only: [:index, :new, :create, :activate]
  load_and_authorize_resource
  skip_load_and_authorize_resource only: :activate
  skip_authorization_check only: :activate
	
	def index
	end

  def show
  end

  def new
  end

  def activate
    if @user = User.load_from_activation_token(params[:id])
      @user.activate!
      auto_login(@user)
      redirect_to(user_groups_path, notice: "Welcome #{@user.name}! Start by creating your first group of people you're shopping for.")
    else
      not_authenticated
    end
  end

  def create
    if @user.save
      redirect_to(root_path, notice: 'Welcome to Supermarkit! We have sent you a confirmation email to get started.')
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
