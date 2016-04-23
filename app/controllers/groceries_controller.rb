class GroceriesController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :user_group
  load_and_authorize_resource :grocery, through: :user_group, shallow: true

	def show
    @dashboard = {
      checkout_url: checkout_grocery_path(@grocery),
      itemList: {
        grocery: {
          name: @grocery.name,
          id: @grocery.id,
          url: grocery_path(@grocery)
        },
        items: {
          url: grocery_items_path(@grocery)
        },
        users: format_users,
        modal: {
          addUnmatchedQuery: true,
          queryUrl: auto_complete_grocery_items_path(@grocery, q: ''),
          id: 'add-groceries',
          resultType: 'ItemResult',
          input: {
            placeholder: 'Add your item, like 5 bananas (for $4)',
            queryField: 'query',
            delimiter: '\s*',
            fields: [
              {
                name: 'quantity',
                regex: '([0-9]*)?'
              },
              {
                name: 'query',
                regex: '(.*?)'
              },
              {
                name: 'price',
                regex: '(?:for \$([0-9]*))?'
              }
            ]
          }
        }

      }
    }
    @grocery_store = @grocery.grocery_store
	end

	def new
  end

  def create
    if @grocery.save
      current_user.default_group = @user_group unless current_user.default_group
      redirect_to @grocery
    else
      render :new
    end
	end

	def edit
	end

	def update
    items = params[:grocery][:items] || []

    @grocery.items.delete(@grocery.items - items.map { |item| Item.find_by_id(item[:id]) })
    items.each do |item|
      grocery_item = GroceriesItems.find_or_create_by(
        item: Item.accessible_by(current_ability).find_or_create_by(id: item[:id], name: item[:name].capitalize),
        grocery: @grocery
      )
      grocery_item.update!(item.permit(:quantity, :price)
       .merge!({ requester_id: grocery_item.requester_id || current_user.id }))
    end

    if @grocery.update!(grocery_params)
      render nothing: true
    end
	end

  def checkout
    @checkout_data = {
      grocery_id: @grocery.id,
      users: format_users,
      url: do_checkout_grocery_path(@grocery),
      redirect_url: new_user_group_grocery_path(@grocery.user_group),
      estimated_total: @grocery.total_price_or_estimated.to_f
    }
  end

  def do_checkout
    grocery_payment_params[:payments].each do |payment|
      Payment.create(payment.merge!({ grocery_id: @grocery.id }))
    end
    @grocery.finished_at = DateTime.now

    if @grocery.save
      head :ok
      flash[:notice] = "Checkout complete! When you're ready, make a new list."
    else
      head :internal_server_error
    end
  end

  def email_group
    @grocery.user_group.users.each do |user|
      UserMailer.send_grocery_list_email(user, @grocery).deliver_now
    end

    redirect_to @grocery, notice: 'All kit members have been emailed the grocery list.'
  end

  def recipes
    ingredients = URI.escape(@grocery.items.pluck(:name).join(','))
    uri = URI("http://food2fork.com/api/search?key=#{ENV["FOOD2FORK_KEY"]}&q=#{ingredients}")
    res = Net::HTTP.get(uri)
    render json: JSON.parse(res)
  end

  def set_store
    @grocery_store = GroceryStore
      .create_with(grocery_store_params)
      .find_or_create_by(place_id: params[:grocery_store][:place_id])

    @grocery.grocery_store = @grocery_store

    if @grocery_store.valid? && @grocery.save
      render nothing: true, status: :ok
    else
      render nothing: true, status: :internal_server_error
    end
  end

private

  def format_users
    @grocery.user_group.user_groups_users.map do |user_group_user, h|
      {
        id: user_group_user.user_id,
        name: user_group_user.user.name,
        state: user_group_user.state,
        gravatar: user_group_user.user.gravatar_url(50),
        balance: user_group_user.balance.to_f
      }
    end
  end

  def find_items(ids)
    ids.split(',').flat_map { |id| Item.find(id) }
  end

  def grocery_params
      params.require(:grocery).permit(:name, :description)
  end

  def grocery_item_params
      params.require(:grocery).permit(items: [:id, :quantity, :price])
  end

  def grocery_payment_params
    params.require(:grocery).permit(payments: [:user_id, :price])
  end

  def grocery_store_params
    params.require(:grocery_store).permit(:name, :lat, :lng, :place_id)
  end
end
