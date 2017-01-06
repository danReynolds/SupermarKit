class UserGroups::PaymentsController < ApplicationController
  include SplitController
  initialize_split_controller(:user_group)

  def show
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
end
