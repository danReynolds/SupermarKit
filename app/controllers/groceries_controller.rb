class GroceriesController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :user_group
  load_and_authorize_resource :grocery, through: :user_group, shallow: true

	def show
    @dashboard = {
      recipeLength: @grocery.recipes.length,
      checkout_url: checkout_grocery_path(@grocery),
      itemList: {
        grocery: {
          name: @grocery.name,
          id: @grocery.id,
          url: update_items_grocery_path(@grocery)
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
      },
      emailer: {
        buttonText: 'person',
        url: email_group_grocery_path(@grocery),
        selection: format_users,
        modal: {
          id: 'user-emails',
          queryUrl: auto_complete_users_path(gravatar: true, q: ''),
          resultType: 'UserResult',
          input: {
            placeholder: 'Choose friends to email',
            queryField: 'query',
            fields: [
              {
                name: 'query',
                regex: '(.*)'
              }
            ]
          }
        }
      },
      recipes: {
        selection: format_recipes,
        modal: {
          id: 'recipes',
          category: [
            'Korean',
            'American',
            'Italian',
            'Chinese',
            'Mediterranean',
            'Dessert',
            'Breakfast',
            'Lunch',
            'Barbecue'
          ].sample,
          recipeUrl: "https://api.yummly.com/v1/api/recipe/@externalId?_app_id=#{ENV['YUMMLY_APP_ID']}&_app_key=#{ENV['YUMMLY_APP_KEY']}",
          queryUrl: "https://api.yummly.com/v1/api/recipes?_app_id=#{ENV['YUMMLY_APP_ID']}&_app_key=#{ENV['YUMMLY_APP_KEY']}&requirePictures=true&q=",
          updateUrl: update_recipes_grocery_path(@grocery),
          resultType: 'RecipeResult',
          input: {
            placeHolder: 'Search for recipes',
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
    }
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

	def update_items
    items = params[:grocery][:items] || []
    @grocery.items.delete(@grocery.items - items.map { |item| Item.find_by_id(item[:id]) })
    items.each do |item|
      grocery_item = GroceriesItems.find_or_create_by(
        item: Item.accessible_by(current_ability).find_or_create_by(name: item[:name].capitalize),
        grocery: @grocery
      )
      grocery_item.update!(
        item.permit(:quantity, :price).merge!({ requester_id: grocery_item.requester_id || current_user.id })
      )
    end

    if @grocery.update!(grocery_params)
      head :ok
    end
	end

  def update_recipes
    params[:grocery][:recipes] ||= []
    recipes = grocery_recipe_params[:recipes].map do |recipe_params|
      recipe = Recipe.find_by_external_id(recipe_params[:external_id]) || Recipe.new(recipe_params.except(:items))

      if recipe.new_record?
        recipe.items = recipe_params[:items].map do |item|
          Item.find_or_create_by(name: item[:name])
        end
        recipe.save!
      end
      recipe
    end
    new_items = (recipes - @grocery.recipes).flat_map(&:items)
    removed_items = (@grocery.recipes - recipes).flat_map(&:items)

    @grocery.recipes = recipes
    @grocery.items.delete(removed_items)

    new_items.each do |item|
      GroceriesItems.create(
        grocery: @grocery,
        item: item,
        requester: current_user
      )
    end

    head :ok if @grocery.save!
  end

  def checkout
    @checkout_data = {
      grocery_id: @grocery.id,
      users: format_users(true),
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

    if @grocery.save!
      head :ok
      flash[:notice] = "Checkout complete! When you're ready, make a new list."
    end
  end

  def email_group
    grocery_email_params[:email][:user_ids] ||= []
    grocery_email_params[:email][:user_ids].each do |id|
      UserMailer.send_grocery_list_email(User.find(id), @grocery, grocery_email_params[:email][:message]).deliver_now
    end
    head :ok
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

  def format_users(balance = false)
    @grocery.user_group.user_groups_users.map do |user_group_user, h|
      user_data = {
        id: user_group_user.user_id,
        name: user_group_user.user.name,
        state: user_group_user.state,
        image: user_group_user.user.gravatar_url(50),
      }
      user_data[:balance] = user_group_user.balance.to_f if balance
      user_data
    end
  end

  def format_recipes
    @grocery.recipes.map do |recipe|
      {
        externalId: recipe.external_id,
        image: recipe.image_url,
        name: recipe.name,
        rating: recipe.rating,
        timeInSeconds: recipe.timeInSeconds,
        url: recipe.url
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

  def grocery_recipe_params
    params.require(:grocery).permit({
      recipes: [
        :external_id,
        :name,
        :url,
        :image_url,
        :rating,
        :id,
        :timeInSeconds,
        {
          items: [:name]
        }
      ]
    })
  end

  def grocery_email_params
    params.require(:grocery).permit(email: [:message, user_ids: []])
  end

  def grocery_store_params
    params.require(:grocery_store).permit(:name, :lat, :lng, :place_id)
  end
end
