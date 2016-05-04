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
    @user_data = user_data
    @banner_image = UserGroup::BANNER_IMAGES.sample
  end

  def create
    if @user_group.save
      @user_group.users << (User.find(params[:user_group][:user_ids].split(",")) << current_user)
      @user_group.user_groups_users
       .find_by_user_id(current_user.id)
       .update_attributes(state: UserGroupsUsers::ACCEPTED)

      current_user.update_attribute(:default_group, @user_group) unless current_user.default_group
      redirect_to @user_group
    else
      @user_data = user_data
      @banner_image = UserGroup::BANNER_IMAGES.sample
      render :new
    end
  end

  def edit
    @user_data = user_data
  end

  def update
    @user_group.users = User.find(params[:user_group][:user_ids].split(","))

    if @user_group.update_attributes(user_group_params)
      redirect_to user_groups_path
    else
      render action: :edit
    end
  end

  def accept_invitation
    @user_group_user = @user_group.user_groups_users.find_by_user_id(current_user.id)
    @user_group_user.state = UserGroupsUsers::ACCEPTED
    current_user.update_attribute(:default_group, @user_group) unless current_user.default_group

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

  def user_data
      {
        title: 'Kit members',
        buttonText: 'Modify',
        selection: @user_group.users.map do |user|
          {
            name: user.name,
            id: user.id,
            gravatar: user.gravatar_url
          }
        end,
        formElement: 'user_group_user_ids',
        modal: {
          id: 'change-members',
          queryUrl: auto_complete_users_path(gravatar: true, q: ''),
          resultType: 'UserResult',
          chipType: 'UserChip',
          input: {
            placeholder: 'Add friends to your Kit',
            queryField: 'query',
            fields: [
              {
                name: 'query',
                regex: '(.*)'
              }
            ]
          }
        }
      }
  end
end
