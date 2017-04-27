class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :activate], raise: false
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
      redirect_to user_groups_path, notice: "Welcome #{@user.name}! Get started by creating your first Kit."
    else
      flash[:notice] = 'Invalid confirmation token.'
      not_authenticated
    end
  end

  def default_group
    @user_group = UserGroup.find(params[:user_group])
    authorize! :read, @user_group

    @user.default_group = @user_group
    if @user.save!
      redirect_to @user_group, notice: "#{@user_group.name} is now your default Kit."
    end
  end

  def create
    if @user.save
      redirect_to root_path, notice: 'Welcome to Supermarkit! We have sent you a confirmation email with a link to activate your account.'
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def auto_complete
    users = User.accessible_by(current_ability).with_name(params[:q]).map do |user|
      results = {
        id: user.id,
        name: user.name
      }
      results.tap do
        results[:image] = user.gravatar_url if params[:image]
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
      render json: @user.errors, status: :unprocessable_entity
    end
  end

private

	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end
end
