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
    @user_group.user_ids = user_group_params[:user_ids].split(',') << current_user.id
    if @user_group.save
      @user_group.user_groups_users
       .find_by_user_id(current_user.id)
       .update_attribute(:state, UserGroupsUsers::ACCEPTED)

      current_user.update_attribute(:default_group, @user_group) unless current_user.default_group
      redirect_to @user_group, notice: 'Kit created! When you are ready, create your first grocery list.'
    else
      @kit_data = kit_data
      @banner_image = UserGroup::BANNER_IMAGES.sample
      render :new
    end
  end

  def edit
    @kit_data = kit_data
  end

  def payments
    grocery_payments = @user_group.finished_groceries.map do |grocery|
      receipt = grocery.receipt.url if grocery.receipt.file?
      {
        date: grocery.finished_at.to_i,
        date_formatted: grocery.finished_at.strftime('%A, %d %b %Y %l:%M %p').to_s,
        id: grocery.id,
        name: grocery.name,
        receipt: receipt,
        total: grocery.payments_total.format,
        items: grocery.items.map do |item|
          {
            name: item[:name],
            price: item.grocery_item(grocery).price.format(symbol: false)
          }
        end,
        payments: grocery.payments.map do |payment|
          {
            id: payment.id,
            price: payment.price.format,
            payer: payment.user.name,
            image: payment.user.gravatar_url
          }
        end
      }
    end

    user_payments = @user_group.payments.map do |payment|
      {
        date: payment.created_at.to_i,
        date_formatted: payment.created_at.strftime('%A, %d %b %Y %l:%M %p').to_s,
        id: payment.id,
        reason: payment.reason,
        total: payment.price.format,
        payee: {
          name: payment.payee.name,
          image: payment.payee.gravatar_url
        },
        payer: {
          name: payment.payer.name,
          image: payment.payer.gravatar_url
        }
      }
    end

    @payment_data = {
      payments: (grocery_payments + user_payments).sort_by { |payment| payment[:date] }.reverse
    }
  end

  def update
    update_params = update_user_group_params
    update_params[:user_ids] = update_params[:user_ids].split(',')
    remaining_users = User.find(update_params[:user_ids])
    removed_users = @user_group.users - remaining_users

    removed_users.each do |user|
      if user.default_group == @user_group
        user.update_attribute(:default_group, nil)
      end
    end

    if params[:default_group]
      current_user.update_attribute(:default_group, @user_group)
    elsif current_user.default_group == @user_group
      current_user.update_attribute(:default_group, nil)
    end

    if @user_group.update!(update_params)
      redirect_to @user_group
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
      user_group_payment_params.merge!({
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
    params.require(:user_group).permit(:name, :description, :privacy, :banner, :user_ids)
  end

  def user_group_payment_params
    params.require(:user_group).permit(:payee_id, :reason, :price)
  end

  def update_user_group_params
    params.require(:user_group).permit(:name, :description, :banner, :user_ids)
  end

  def user_payment_data
    user_groups_users = @user_group.user_groups_users
    user_groups_users.where(user: current_user).union(user_groups_users).map do |user_group_user|
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
