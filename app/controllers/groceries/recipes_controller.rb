class Groceries::RecipesController < ApplicationController
  include Matcher
  load_and_authorize_resource :grocery

  def update
    recipes = grocery_recipe_params.map do |recipe_params|
      Recipe.find_by_external_id(
        recipe_params[:external_id]
      ) || create_recipe(recipe_params)
    end

    remove_old_items(@grocery.recipes - recipes)
    add_new_items(recipes - @grocery.recipes)
    @grocery.recipes = recipes

    render json: @grocery.recipes
  end

  private

  def grocery_recipe_params
    params.require(:grocery).permit(
      recipes: [
        :external_id, :name, :url, :image_url, :rating, :timeInSeconds,
        ingredientDescriptions: [], ingredients: []
      ]
    ).fetch(:recipes, [])
  end

  # Adds the items from new recipes to the grocery list
  def add_new_items(recipes)
    items = @grocery.items
    recipes.each do |recipe|
      recipe.items_recipes.where.not(item: items).each do |item_recipe|
        GroceriesItems.create!(
          grocery: @grocery,
          item: item_recipe.item,
          requester: current_user,
          quantity: item_recipe.quantity,
          units: item_recipe.units
        )
      end
    end
  end

  # Removes the items from no longer included recipes
  def remove_old_items(recipes)
    @grocery.items.delete(recipes.flat_map(&:items))
  end

  def create_recipe(recipe_params)
    items_recipes = build_items_recipes(recipe_params)
    Recipe.new(recipe_params).tap do |recipe|
      recipe.items_recipes << items_recipes
      recipe.save!
    end
  end

  def build_items_recipes(recipe_params)
    ingredients = recipe_params.delete(:ingredients)

    parsed_descriptions = parse_ingredients(
      recipe_params.delete(:ingredientDescriptions)
    )

    ingredients.map do |ingredient|
      item = Item.find_or_create_by(name: ingredient)

      # Find the ingredients line including units and amount that matches
      # the exact item name returned separately from the API
      match = Matcher.new(ingredient).find_match(
        parsed_descriptions, 0, :ingredient
      ).result

      ItemsRecipes.new(parse_item_recipe_attributes(item, match))
    end
  end

  def parse_item_recipe_attributes(item, match)
    # If there is a container, such as "1 15.5 oz can of spinach"
    # we want to capture the container amount, 15.5 oz
    quantity = match.container_amount || match.amount || 1

    # Quantity might have been specified as a range, take average
    quantity = quantity.sum / quantity.size.to_f if quantity.is_a?(Array)
    {
      item: item,
      units: match.container_unit || match.unit,
      quantity: quantity
    }
  end

  def parse_ingredients(ingredient_descriptions)
    ingredient_descriptions.map do |line|
      # Remove trailing instructions for the item to improve match similarity
      ingredient_information = line.split(',').first
      begin
        Ingreedy.parse(ingredient_information)
      rescue Ingreedy::ParseFailed
        Ingreedy::Parser::Result.new.tap do |result|
          result.ingredient = ingredient_information
        end
      end
    end
  end
end
