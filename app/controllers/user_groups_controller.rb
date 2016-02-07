class UserGroupsController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource

  def index
  end

  def show
    @user = current_user
    @active_grocery = @user_group.active_groceries.first
  end

  def new
    @members_data = members_data
  end

  def create
    users = User.find(params[:user_group][:user_ids].split(",")) << current_user
    @user_group.emblem = UserGroup::EMBLEMS.sample

    if @user_group.save
      @user_group.users << users
      @user_group.user_groups_users
                 .find_by_user_id(current_user.id)
                 .update_attributes(state: UserGroupsUsers::ACCEPTED)

      current_user.update_attribute(:default_group, @user_group) unless current_user.default_group

      redirect_to new_user_group_grocery_path(@user_group)
    else
      @members_data = members_data
      render :new
    end
  end

  def edit
    @members_data = members_data
  end

  def update
    users = User.find(params[:user_group][:user_ids].split(","))
    @user_group.users = users

    if @user_group.update_attributes(user_group_params)
      redirect_to @user_group
    else
      render action: :edit
    end
  end

  def metrics
    groceries = @user_group.finished_groceries
    @metrics = {
      grocery_spending: groceries.map { |grocery| [grocery.finished_at.to_date, grocery.total] },
      grocery_cost: groceries.last(5).map { |grocery| { name: grocery.name, data: { grocery.finished_at.to_date => grocery.total } } },
      grocery_items: groceries.last(5).map { |grocery| { name: grocery.name, data: { grocery.finished_at.to_date => grocery.items.count } } }
    }
  end

  def accept_invitation
    @user_group_user = @user_group.user_groups_users.find_by_user_id(current_user.id)
    @user_group_user.state = UserGroupsUsers::ACCEPTED

    if @user_group_user.save
      flash[:notice] = "You've been added to #{@user_group.name}."
      redirect_to @user_group
    else
      flash[:error] = 'Unable to join Kit.'
      redirect_to action: :index
    end
  end

private
  def user_group_params
    params.require(:user_group).permit(:name, :description, :privacy, :banner)
  end

  def members_data
    users = @user_group.user_groups_users.map do |user_group_user|
      {
        id: user_group_user.user.id,
        name: user_group_user.user.name,
        state: user_group_user.state,
        gravatar: user_group_user.user.gravatar_url(50)
      }
    end
    {
      multiselect: {
        title: 'Group members',
        button: 'Change',
        modal: '#change-members',
        hiddenField: '#user_group_user_ids'
      },
      reveal: {
        url: '/users/auto_complete',
        modal: '#change-members',
        selection: users
      }
    }
  end
end
