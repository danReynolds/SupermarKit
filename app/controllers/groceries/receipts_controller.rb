class Groceries::ReceiptsController < ApplicationController
  include Matcher
  include SplitController
  include ReceiptProcessor
  initialize_split_controller(:grocery)

  TOTAL_KEYWORDS = ['Total', 'Subtotal', 'Balance', 'Debit tend'].freeze

  def show
    @components = {
      receipt: {
        token: form_authenticity_token,
        url: grocery_receipts_path(@grocery),
        confirm_url: confirm_grocery_receipts_path(@grocery),
        checkout_url: grocery_checkouts_path(@grocery)
      }
    }
  end

  def create
    @grocery.update!(receipt: params[:file])
    match_results = process_matches(
      ReceiptProcessor.new(@grocery.receipt.url).process
    )
    render json: render_matches(match_results)
  end

  def confirm
    grocery_receipt_params[:matches].each do |match|
      item = Item.accessible_by(current_ability).find_or_create_by(
        name: match[:name]
      )
      GroceriesItems.create_with(requester: current_user).find_or_create_by(
        item: item,
        grocery: @grocery
      ).update!(price: match[:price])
    end

    render json: { uploader_id: current_user.id }
  end

  private

  def grocery_receipt_params
    params.require(:grocery).permit(matches: [:name, :price])
  end

  def render_matches(matches)
    # Add new items and update existing items with the determined prices
    matches.tap do ||
      matches[:list].each do |match|
        if @grocery.items.where(name: match[:name]).length.zero?
          match.merge!(new: true)
        end
      end
    end
  end

  def process_matches(processed_receipt)
    processed_receipt.inject(list: [], total: 0) do |matches, capture|
      matches.tap do |_|
        process_match(
          Matcher.new(capture.first.strip.downcase.capitalize),
          matches,
          capture[1].to_f
        )
      end
    end
  end

  def process_match(matcher, matches, price)
    return if total_match(matcher, matches, price)
    return unless match = matcher.find_match(@grocery.items.pluck(:name)) ||
      matcher.find_match(Item.accessible_by(current_ability).pluck(:name))
    return if aggregate_match(match, matches, price)

    matches[:list] << {
      name: match.result,
      price: price,
      similarity: match.similarity
    }
  end

  # Aggregate duplicate items together
  def aggregate_match(match, matches, price)
    return unless aggregate_match = matches[:list].detect do |existing_match|
      existing_match[:name] == match.result
    end
    aggregate_match[:price] += price
  end

  # There is a special case for matches to the total price
  def total_match(matcher, matches, price)
    return unless matcher.find_match(TOTAL_KEYWORDS)
    # Multiple matches for a total keyword favor the largest value
    matches[:total] = [price, matches[:total]].max
  end
end
