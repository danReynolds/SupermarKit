class GroceriesController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :user_group
  load_and_authorize_resource :grocery, through: :user_group, shallow: true

  def show
    @dashboard = {
      recipeLength: @grocery.recipes.length,
      receipt_url: grocery_receipts_path(@grocery),
      manage_url: user_group_path(@grocery.user_group),
      itemList: itemlist_params,
      emailer: emailer_params,
      recipes: recipes_params,
      location: location_params
    }
  end

  def create
    current_user.default_group = @user_group unless current_user.default_group
    if @grocery.save && current_user.save
      redirect_to @grocery
    else
      render json: @grocery.errors, status: :unprocessable_entity
    end
  end

  def edit
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
        id: @grocery.id,
        name: @grocery.name,
        url: grocery_items_path(@grocery)
      },
      items: {
        url: grocery_items_path(@grocery),
        unit_types: UNIT_TYPES.inject({}) do |acc, unit|
          acc.tap { acc[unit] = nil }
        end
      },
      users: ActiveModelSerializers::SerializableResource.new(
        @grocery.user_group.users
      ).as_json,
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
            { name: 'quantity', regex: '([0-9]*)?' },
            { name: 'units', regex: '(?:(.*) of)?' },
            { name: 'query', regex: '(.*?)' },
            { name: 'price', regex: '(?:for \$([0-9]*))?' }
          ]
        }
      }
    }
  end

  def emailer_params
    {
      buttonText: 'person',
      url: email_group_grocery_path(@grocery),
      selection: ActiveModelSerializers::SerializableResource.new(
        @grocery.user_group.users
      ).as_json,
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
      selection: ActiveModelSerializers::SerializableResource.new(
        @grocery.recipes
      ).as_json,
      yourRecipeHeader: 'Your Recipes',
      suggestedReciperHeader: 'Suggested Recipes',
      modal: {
        id: 'recipes',
        category: CONFIGURABLES[:food_categories].sample,
        recipeUrl: "https://api.yummly.com/v1/api/recipe/@externalId?_app_id=#{ENV['YUMMLY_APP_ID']}&_app_key=#{ENV['YUMMLY_APP_KEY']}",
        queryUrl: "https://api.yummly.com/v1/api/recipes?_app_id=#{ENV['YUMMLY_APP_ID']}&_app_key=#{ENV['YUMMLY_APP_KEY']}&requirePictures=true&q=",
        updateUrl: grocery_recipes_path(@grocery),
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

  def grocery_params
    params.require(:grocery).permit(:name, :description)
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
