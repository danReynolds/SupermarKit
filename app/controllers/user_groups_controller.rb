class UserGroupsController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource

  def index
  end

  def show
    @management_data = {
      modal: '#pay-modal',
      url: do_payment_user_group_path(@user_group),
      users: user_payment_data
    }
  end

  def new
    @kit_data = kit_data
    @banner_image = UserGroup::BANNER_IMAGES.sample
  end

  def create
    if @user_group.save
      @user_group.users << (User.find(params[:user_group][:user_ids].split(",")) << current_user)
      @user_group.user_groups_users
       .find_by_user_id(current_user.id)
       .update_attributes(state: UserGroupsUsers::ACCEPTED)

      current_user.update_attribute(:default_group, @user_group) unless current_user.default_group
      redirect_to new_user_group_grocery_path(@user_group)
    else
      @kit_data = kit_data
      @banner_image = UserGroup::BANNER_IMAGES.sample
      render :new
    end
  end

  def edit
    @kit_data = kit_data
  end

  def update
    remaining_users = params[:user_group][:user_ids].split(",")
    removed_users = @user_group.users - remaining_users
    @user_group.users = User.find(remaining_users)

    removed_users.each do |user|
      if user.default_group == @user_group
        user.update_attribute(:default_group, nil)
      end
    end

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

  def do_payment
    UserPayment.create!(
      user_group_params.merge!({
        payer_id: current_user.id,
        user_group_id: @user_group.id
      })
    )
    render json: {
      data: user_payment_data
    }
  end

private
  def user_group_params
    params.require(:user_group).permit(:payee_id, :price, :name, :description, :privacy, :banner)
  end

  def user_payment_data
    @user_group.user_groups_users.partition do |user_group_user|
      user_group_user.user == current_user
    end.flatten.map do |user_group_user|
      user = user_group_user.user
      {
        id: user.id,
        image: user.gravatar_url,
        name: user.name,
        balance: user_group_user.balance.to_f
      }
    end
  end

  def kit_data
      {
        title: 'Kit members',
        buttonText: 'Modify',
        formElement: 'user_group_user_ids',
        buttonText: 'person',
        selection: @user_group.users.map do |user|
          {
            name: user.name,
            id: user.id,
            image: user.gravatar_url
          }
        end,
        modal: {
          id: 'change-members',
          queryUrl: auto_complete_users_path(image: true, q: ''),
          resultType: 'UserResult',
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
