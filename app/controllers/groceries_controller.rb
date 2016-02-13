class GroceriesController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :user_group
  load_and_authorize_resource :grocery, through: :user_group, shallow: true

  def index
    respond_to do |format|
      format.json do
        groceries = @groceries.order('created_at DESC').map do |grocery|
          {
            id: grocery.id,
            name: grocery.name,
            description: grocery.description,
            count: grocery.items.count,
            cost: grocery.total.to_money.format,
            finished: grocery.finished?
          }
        end
        render json: { data: groceries }
      end
    end
	end

	def show
    @items_data = {
      itemsUrl: grocery_items_path(@grocery),
      usersUrl: list_users_user_group_path(@grocery.user_group)
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
	end

  def finish
    current_items = find_items(params[:finish][:current_ids])
    next_items = find_items(params[:finish][:next_ids])

    @grocery.items = current_items
    @grocery.finished_at = DateTime.now

    new_grocery = Grocery.new(
      name: params[:finish][:name],
      description: params[:finish][:description],
      items: next_items,
      user_group: @grocery.user_group
    )

    begin
      Grocery.transaction do
        @grocery.save! && new_grocery.save!
        redirect_to new_grocery, notice: 'Your new grocery list is setup and ready to use.'
      end
    rescue ActiveRecord::RecordInvalid
      redirect_to @grocery, alert: 'There was a problem finishing your list.'
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

  def find_items(ids)
    ids.split(',').flat_map { |id| Item.find(id) }
  end

  def grocery_params
    params.require(:grocery).permit(:name, :description)
  end

  def grocery_store_params
    params.require(:grocery_store).permit(:name, :lat, :lng, :place_id)
  end
end
