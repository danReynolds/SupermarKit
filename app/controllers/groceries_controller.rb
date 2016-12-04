class GroceriesController < ApplicationController
  include Matcher

  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :user_group
  load_and_authorize_resource :grocery, through: :user_group, shallow: true

  TOTAL_KEYWORDS = ['Total', 'Subtotal', 'Balance', 'Debit tend'].freeze

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
      render json: @grocery.errors, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update_items
    all_item_params = grocery_item_params[:items] || []
    existing_items = Item.accessible_by(current_ability)
      .where(id: all_item_params.map { |i| i[:id] })
    existing_grocery_items = GroceriesItems.where(grocery: @grocery)

    items = all_item_params.map do |item_params|
      existing_items.find_or_create_by(
        name: item_params[:name]
      ).tap do |item|
        grocery_item = existing_grocery_items.find_or_create_by(
          item: item,
          grocery: @grocery
        )
        grocery_item.update!(
          item_params.slice(:quantity, :price, :units).merge({
            requester_id: grocery_item.requester_id || current_user.id,
            units: item_params[:units]
          }).to_h
        )
      end
    end
    @grocery.items.delete(@grocery.items - items)

    head :ok
  end

  def receipt
    @receipt_data = {
      token: form_authenticity_token,
      url: upload_receipt_grocery_path(@grocery),
      confirm_url: confirm_receipt_grocery_path(@grocery),
      checkout_url: checkout_grocery_path(@grocery)
    }
  end

  def upload_receipt
    @grocery.update!({ receipt: params[:file] })

    # Initialize Tesseract with English, only capital letters
    engine = Tesseract::Engine.new do |e|
      e.path = '/usr/local/share'
      e.language  = :en
      e.blacklist = ['|']
    end

    # Retrieve the cleaned file from Amazon and process its text
    file = open(@grocery.receipt.url)
    processed_receipt = engine.text_for(file.path).strip.split("\n")
    # Match tesseract captures to items in the grocery list
    captures = processed_receipt
      .map { |line| line.match(/((?:[A-za-z]+\s)+).*?(\d*\.\d+)/) }
      .compact.map(&:captures)
    match_results = captures.inject({ matches: [], total: 0 }) do |matches, capture|
      matches.tap do |acc|
        matcher = Matcher.new(capture.first.strip!.downcase.capitalize)

        # There is a special case for matches to the total price
        if match = matcher.find_match(TOTAL_KEYWORDS)
          # Multiple matches for a total keyword favor the largest value
          acc[:total] = [capture[1].to_f, acc[:total]].max
        elsif match = matcher.find_match(@grocery.items.pluck(:name)) || matcher.find_match(Item.all.pluck(:name))
          # Aggregate duplicate items together
          aggregate_match = acc[:matches].detect { |existing_match| existing_match[:name] == match.result }
          if aggregate_match
            aggregate_match.merge!({ price: aggregate_match[:price] += capture[1].to_f })
          else
            acc[:matches] << {
              name: match.result,
              price: capture[1].to_f,
              similarity: match.similarity
            }
          end
        end
      end
    end

    # Add new items and update existing items with the determined prices
    match_results[:matches].each do |match|
      match.merge!({ new: true }) if @grocery.items.where(name: match[:name]).length.zero?
    end

    render json: {
      data: match_results
    }
  end

  def confirm_receipt
    grocery_confirm_receipt_params[:matches].each do |match|
      item = Item.find_or_create_by(name: match[:name])
      unless @grocery.items.find_by_id(item.id)
        @grocery.items << item
        item.grocery_item(@grocery).update!(requester: current_user)
      end
      item.grocery_item(@grocery).update!(price: match[:price])
    end

    render json: {
      data: { uploader_id: current_user.id }
    }
  end

  def checkout
    @checkout_data = {
      grocery_id: @grocery.id,
      users: format_users(true),
      url: do_checkout_grocery_path(@grocery),
      redirect_url: user_group_path(@grocery.user_group),
      total: params[:total].try(:to_f) || @grocery.total_price_or_estimated.to_f,
      uploader_id: params[:uploader_id].try(:to_i)
    }
  end

  def do_checkout
    grocery_payment_params[:payments].each do |payment|
      GroceryPayment.create(payment.merge({ grocery_id: @grocery.id }).to_h)
    end
    @grocery.finished_at = DateTime.now

    if @grocery.save!
      if slackbot = @grocery.user_group.slack_bot
        if (slackbot.enabled?(SlackMessage::SEND_CHECKOUT_MESSAGE))
          slackbot.send_message(SlackMessage::SEND_CHECKOUT_MESSAGE, @grocery)
        end

        if (@grocery.receipt.present? && slackbot.enabled?(SlackMessage::SEND_GROCERY_RECEIPT))
          slackbot.send_message(SlackMessage::SEND_GROCERY_RECEIPT, @grocery)
        end
      end

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
        id: @grocery.id,
        name: @grocery.name,
        url: update_items_grocery_path(@grocery)
      },
      items: {
        url: grocery_items_path(@grocery),
        unit_types: UNIT_TYPES.inject({}) do |acc, unit|
          acc.tap { acc[unit] = nil }
        end
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
      selection: ActiveModelSerializers::SerializableResource.new(@grocery.recipes).as_json,
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

  def format_users(balance = false)
    @grocery.user_group.user_groups_users.includes(:user).map do |user_group_user, h|
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

  def find_items(ids)
    ids.split(',').flat_map { |id| Item.find(id) }
  end

  def grocery_params
    params.require(:grocery).permit(:name, :description)
  end

  def grocery_item_params
    params.require(:grocery).permit(items: [:id, :quantity, :price, :units, :name])
  end

  def grocery_payment_params
    params.require(:grocery).permit(payments: [:user_id, :price])
  end

  def grocery_confirm_receipt_params
    params.require(:grocery).permit(matches: [:name, :price])
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
