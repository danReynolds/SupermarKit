class Groceries::CheckoutsController < ApplicationController
  include SplitController
  initialize_split_controller(:grocery)

  def show
    @checkout_data = {
      grocery_id: @grocery.id,
      users: ActiveModelSerializers::SerializableResource.new(
        @grocery.user_group.users,
        with_balance: @grocery.user_group
      ).as_json,
      url: grocery_checkouts_path(@grocery),
      redirect_url: user_group_path(@grocery.user_group),
      total: params[:total].try(:to_f) || @grocery.total_price_or_estimated.to_f,
      uploader_id: params[:uploader_id].try(:to_i)
    }
  end

  def create
    grocery_checkouts_params[:payments].each do |payment|
      GroceryPayment.create(payment.merge(grocery_id: @grocery.id).to_h)
    end
    @grocery.finished_at = DateTime.now
    @grocery.save!

    send_slack_messages
    head :ok
    flash[:notice] = (
      "Checkout complete! When you're ready, make a new grocery list."
    )
  end

  private

  def send_slack_messages
    return unless slackbot = @grocery.user_group.slack_bot

    if slackbot.enabled?(SlackMessage::SEND_CHECKOUT_MESSAGE)
      slackbot.send_message(SlackMessage::SEND_CHECKOUT_MESSAGE, @grocery)
    end

    if @grocery.receipt.present? && slackbot.enabled?(SlackMessage::SEND_GROCERY_RECEIPT)
      slackbot.send_message(SlackMessage::SEND_GROCERY_RECEIPT, @grocery)
    end
  end

  def grocery_checkouts_params
    params.require(:grocery).permit(payments: [:user_id, :price])
  end
end
