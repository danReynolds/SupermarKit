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
      url: do_checkout_grocery_path(@grocery),
      redirect_url: user_group_path(@grocery.user_group),
      total: params[:total].try(:to_f) || @grocery.total_price_or_estimated.to_f,
      uploader_id: params[:uploader_id].try(:to_i)
    }
  end

  def create
  end
end
