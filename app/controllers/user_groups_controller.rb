class UserGroupsController < ApplicationController
  extend HappyPath
  follow_happy_paths
  
  def new
    @user_group = UserGroup.new
  end

  def create
    @user_group = UserGroup.create(user_groups_params)
    users = User.find(params[:user_group][:user_ids].split(",")) << current_user
    @user_group.users << users

    if @user_group.save
      redirect_to @user_group
    else
      render action: :new
    end
  end

  def index
  end

  def show
    @user = current_user
    @user_group = UserGroup.find(params[:id])
    @active_grocery = @user_group.groceries.last
  end

private

  def user_groups_params
    params.require(:user_group).permit(:name, :description)
  end
end