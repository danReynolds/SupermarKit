class UserGroupsController < ApplicationController
  extend HappyPath
  follow_happy_paths
  
  def index
  end

  def show
    @user = current_user
    @user_group = UserGroup.find(params[:id])
    @active_grocery = @user_group.groceries.last
  end

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
    @user_group = UserGroup.find(params[:id])
    users = User.find(params[:user_group][:user_ids].split(","))
    @user_group.users = users

    if @user_group.save
      redirect_to @user_group
    else
      render action: :edit
    end
  end

  def metrics
    @user_group = UserGroup.find(params[:id])
    groceries = @user_group.groceries
    @metrics = { 
      grocery_spending: groceries.map{ |grocery| [grocery.created_at.to_date, grocery.total] },
      grocery_cost: groceries.map{ |grocery| { name: grocery.name, data: { grocery.created_at.to_date => grocery.total } } },
      grocery_items: groceries.map{ |grocery| { name: grocery.name, data: { grocery.created_at.to_date => grocery.items.count } } }
    }
  end

private

  def user_groups_params
    params.require(:user_group).permit(:name, :description)
  end
end