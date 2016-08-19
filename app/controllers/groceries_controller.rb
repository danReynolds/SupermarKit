class GroceriesController < ApplicationController
  include Matcher

  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :user_group
  load_and_authorize_resource :grocery, through: :user_group, shallow: true

  TOTAL_KEYWORDS = ['Total', 'Subtotal'].freeze

  def show
    @dashboard = {
      recipeLength: @grocery.recipes.length,
      receipt_url: receipt_grocery_path(@grocery),
      manage_url: user_group_path(@grocery.user_group),
      itemList: itemlist_params,
      emailer: emailer_params,
      recipes: recipes_params,
      location: location_params
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
    @grocery.items.delete(@grocery.items - items.map { |item| Item.accessible_by(current_ability).find_by_id(item[:id]) })
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

    if @grocery.save!
      render json: {
        data: format_recipes
      }
    end
  end

  def receipt
    @receipt_data = {
      token: form_authenticity_token,
      url: upload_receipt_grocery_path(@grocery),
      skip_url: checkout_grocery_path(@grocery)
    }
  end

  def upload_receipt
    # @grocery.update!({ receipt: params[:file] })

    # Initialize Tesseract with English, only capital letters
    e = Tesseract::Engine.new do |e|
      e.path = '/usr/local/share'
      e.language  = :en
      e.blacklist = [*'a'..'z', '|']
    end

    # Retrieve the cleaned file from Amazon and process its text
    file = open(@grocery.receipt.url(:clean))
    processed_receipt = e.text_for(file.path).strip.split("\n")

    # Match tesseract captures to items in the grocery list
    captures = processed_receipt.map { |line| line.match(/^((?:[A-Z]+\s)+).*?(\d*\.\d+)/) }.compact.map(&:captures)

    match_result = captures.inject({ matches: [], total: 0 }) do |acc, capture|
      acc.tap do |acc|
          matcher = Matcher.new(capture.first.strip!.downcase.capitalize)

          # There is a special case for matches to the total price
          match = matcher.find_match(TOTAL_KEYWORDS)

          if match
              # Multiple matches for a total keyword favor the largest value
              acc[:total] = [capture[1].to_f, acc[:total]].max
          elsif match = matcher.find_match(@grocery.items.pluck(:name)) || matcher.find_match(Item.all.pluck(:name))
              item = Item.find_by_name(match.name)
              acc[:matches] << {
                  id: item.id,
                  name: item.name,
                  price: capture[1],
                  similarity: match.similarity
              }
          end
      end
    end

    render json: {
        data: match_result
    }
  end

  def checkout
    @checkout_data = {
      grocery_id: @grocery.id,
      users: format_users(true),
      url: do_checkout_grocery_path(@grocery),
      redirect_url: user_group_path(@grocery.user_group),
      estimated_total: @grocery.total_price_or_estimated.to_f
    }
  end

  def do_checkout
    grocery_payment_params[:payments].each do |payment|
      GroceryPayment.create(payment.merge!({ grocery_id: @grocery.id }))
    end
    @grocery.finished_at = DateTime.now

    if @grocery.save!
      head :ok
      flash[:notice] = "Checkout complete! When you're ready, make a new grocery list."
    end
  end

  def email_group
    grocery_email_params[:email][:user_ids] ||= []
    grocery_email_params[:email][:user_ids].each do |id|
      UserMailer.send_grocery_list_email(User.find(id), @grocery, grocery_email_params[:email][:message]).deliver_now
    end
    head :ok
  end

  def update_store
    if params[:grocery][:store]
      @grocery.grocery_store = GroceryStore.create_with(grocery_store_params[:store])
        .find_or_create_by(place_id: grocery_store_params[:store][:place_id])

      unless @grocery.grocery_store.valid? && @grocery.save
        return head :internal_server_error
      end
    else
      @grocery.update_attribute(:grocery_store, nil)
    end

    head :ok
  end

private

  def itemlist_params
    {
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
    }
  end

  def emailer_params
    {
      buttonText: 'person',
      url: email_group_grocery_path(@grocery),
      selection: format_users,
      modal: {
        id: 'user-emails',
        queryUrl: auto_complete_users_path(image: true, q: ''),
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
    }
  end

  def location_params
    {
      url: update_store_grocery_path(@grocery),
      place_id: @grocery.grocery_store.try(:place_id)
    }
  end

  def recipes_params
    {
      selection: format_recipes,
      yourRecipeHeader: 'Your Recipes',
      suggestedReciperHeader: 'Suggested Recipes',
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
  end

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
    params.require(:grocery).permit({
      store: [
        :name,
        :lat,
        :lng,
        :place_id
      ]
    })
  end
end
