class UserGroupsController < ApplicationController

  def new
    @user_group = UserGroup.new
  end

  def create
    @user_group = UserGroup.new(user_groups_params)
    users = User.find(params[:user_group][:user_ids].split(","))
    @user_group << users

    if @user_group.save
      redirect_to @user_group
    else
      render action: :new
    end
  end

  def index
  end

  def show
    raise
  end

private

  def user_groups_params
    params.require(:user_group).permit(:name, :description)
  end
end