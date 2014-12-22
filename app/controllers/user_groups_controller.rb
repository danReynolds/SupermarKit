class UserGroupsController < ApplicationController

  def new
    @user_group = UserGroup.new
  end

  def create
    @user_group = UserGroup.create(user_groups_params)
    users = User.find(params[:user_group][:user_ids].split(","))
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

  def groceries
    user_group = UserGroup.find(params[:id])
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

private

  def user_groups_params
    params.require(:user_group).permit(:name, :description)
  end
end