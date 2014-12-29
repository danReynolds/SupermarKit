class UserGroupsController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource

  def index
  end

  def show
    @user = current_user
    @active_grocery = @user_group.active_groceries.last
  end

  def new
  end

  def create
    users = User.find(params[:user_group][:user_ids].split(",")) << current_user

    if @user_group.save
      @user_group.users << users
      redirect_to @user_group
    else
      render action: :new
    end
  end

  def edit
    @user_group = UserGroup.find(params[:id])

    @users = @user_group.users.map do |user|
      {
        id: user.id,
        name: user.name
      }
    end
  end

  def update
    users = User.find(params[:user_group][:user_ids].split(","))
    @user_group.users = users

    if @user_group.save
      redirect_to @user_group
    else
      render action: :edit
    end
  end

  def metrics
    groceries = @user_group.finished_groceries
    @metrics = { 
      grocery_spending: groceries.map{ |grocery| [grocery.finished_at.to_date, grocery.total] },
      grocery_cost: groceries.map{ |grocery| { name: grocery.name, data: { grocery.finished_at.to_date => grocery.total } } },
      grocery_items: groceries.map{ |grocery| { name: grocery.name, data: { grocery.finished_at.to_date => grocery.items.count } } }
    }
  end

private
  def user_group_params
    params.require(:user_group).permit(:name, :description)
  end
end