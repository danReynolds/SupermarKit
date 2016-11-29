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
    @new_data = new_data
    @banner_image = UserGroup::BANNER_IMAGES.sample
  end

  def create
    @user_group.user_ids = user_group_params[:user_ids].split(',') << current_user.id
    @user_group.owner = current_user

    if @user_group.save
      @user_group.user_groups_users
       .find_by_user_id(current_user.id)
       .update_attribute(:state, UserGroupsUsers::ACCEPTED)

      current_user.update_attribute(:default_group, @user_group) unless current_user.default_group
      redirect_to @user_group, notice: 'Kit created! When you are ready, create your first grocery list.'
    else
      render json: @user_group.errors, status: :unprocessable_entity
    end
  end

  def edit
    @edit_data = edit_data
  end

  def payments
    grocery_payments = @user_group.finished_groceries.includes(:items).map do |grocery|
      receipt = grocery.receipt.url if grocery.receipt.file?
      {
        date: grocery.finished_at,
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
        payments: grocery.payments.includes(:user).map do |payment|
          {
            id: payment.id,
            price: payment.price.format,
            payer: payment.user.name,
            image: payment.user.gravatar_url
          }
        end
      }
    end

    user_payments = @user_group.payments.includes(:payee, :payer).map do |payment|
      {
        date: payment.created_at,
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
      payments: (grocery_payments + user_payments)
        .sort_by { |payment| payment[:date].to_f }.reverse
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

    integrations = JSON.parse(params[:integrations]).with_indifferent_access
    slack = integrations[:slack]
    api_token = slack[:api_token]
    slackbot = @user_group.slack_bot

    if api_token
      slackbot ||= SlackBot.create(user_group: @user_group)
      slackbot.slack_messages = slack[:message_types].map do |type, message_params|
        message = slackbot.slack_messages.find_or_create_by(message_type: type)

        message.tap do |updated_message|
          message.update!(message_params)
        end
      end
      slackbot.update!(api_token: api_token)
    else
      slackbot.destroy if slackbot
    end

    if @user_group.update(update_params)
      flash[:notice] = 'Kit successfully updated.'

      # Evict cache entry for user's abilities
      current_user.reload
      @current_ability = nil

      if can? :read, @user_group
        render json: { redirect_url: user_group_path(@user_group) }
      else
        render json: { redirect_url: user_groups_path }
      end
    else
      error_data = {
        errors: @user_group.errors.messages.map do |field, error|
          "#{field}: #{error.first}"
        end
      }
      render status: :internal_server_error, json: error_data
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

  def leave
    @user_group.users.delete(current_user)
    current_user.update_attribute(:default_group, nil) if current_user.default_group == @user_group

    redirect_to user_groups_path, notice: "You have been removed from #{@user_group.name}'s Kit"
  end

  def do_payment
    UserPayment.create!(
      user_group_payment_params.merge({
        payer_id: current_user.id,
        user_group_id: @user_group.id
      }.to_h)
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
    params.require(:user_group).permit(
      :name,
      :description,
      :banner,
      :user_ids,
      :owner_id,
    )
  end

  def user_payment_data
    @user_group.user_groups_users.includes(:user)
      .partition { |u| u.user == current_user }.flatten.map do |user_group_user|
      user = user_group_user.user
      {
        id: user.id,
        image: user.gravatar_url,
        name: user.name,
        balance: user_group_user.balance.to_f
      }
    end
  end

  def new_data
    {
      title: 'Kit members',
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

  def edit_data
    {
      url: user_group_path(@user_group),
      modal: modal_data,
      multiselect: {
        buttonText: 'person'
      },
      userGroupTransfer: {
        owner: @user_group.owner.id,
      },
      userGroupBanner: {
        url: view_context.image_path(@user_group.banner.url(:standard))
      },
      userGroupSettings: {
        name: @user_group.name,
        description: @user_group.description,
        default_group: current_user.default_group == @user_group,
        badge: @user_group.privacy == UserGroup::PUBLIC ? 'badge' : 'badge secondary',
        privacyDisplay: @user_group.privacy.humanize
      },
      userGroupIntegrations: {
        slack: slack_data
      }
    }
  end

  def slack_data
    slack_messages = @user_group.slack_messages
    {
      api_token: @user_group.slack_bot.try(:api_token),
      name: 'Slack',
      message_types: CONFIGURABLES[:slack_messages].map do |message_data|
        message_data.dup.tap do |message|
          if slack_message = slack_messages.find_by_message_type(message_data[:id])
            message.merge(slack_message.as_json
              .with_indifferent_access.slice(:format, :enabled))
          end
          message[:enabled] ||= false
        end
      end
    }
  end

  def modal_data
    {
      id: 'change-members',
      queryUrl: auto_complete_users_path(image: true, q: ''),
      resultType: 'UserResult',
      selection: @user_group.users.map do |user|
        {
          name: user.name,
          id: user.id,
          image: user.gravatar_url
        }
      end,
      input: {
        placeholder: 'Change who is in your Kit',
        queryField: 'query',
        fields: [
          {
            name: 'query',
            regex: '(.*)'
          }
        ]
      }
    }
  end
end
