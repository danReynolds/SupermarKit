class UsersController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create, :activate]
  load_and_authorize_resource
  skip_load_and_authorize_resource only: :activate
  skip_authorization_check only: :activate

  def show
  end

  def new
  end

  def edit
  end

  def activate
    if @user = User.load_from_activation_token(params[:id])
      @user.activate!
      auto_login(@user)
      redirect_to user_groups_path, notice: "Welcome #{@user.name}! Start by creating your first Kit with the people you want to shop with."
    else
      flash[:notice] = 'Invalid confirmation token.'
      not_authenticated
    end
  end

  def create
    if @user.save
      redirect_to(root_path, notice: 'Welcome to Supermarkit! We have sent you a confirmation email to get started.')
    else
      render :new, notice: 'Unable to create user.'
    end
  end

  def auto_complete
    users = User.accessible_by(current_ability).with_name(params[:q]).map do |user|
      results = {
        id: user.id,
        name: user.name
      }
      results.tap do
        results[:gravatar] = user.gravatar_url if params[:gravatar]
      end
    end

    render json: {
      data: users
    }
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to @user
    else
      render :edit, notice: 'Unable to update your profile.'
    end
  end

private

	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end
end
