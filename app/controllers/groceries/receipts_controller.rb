class Groceries::ReceiptsController < ApplicationController
  include Matcher
  include SplitController
  initialize_split_controller(:grocery)

  TOTAL_KEYWORDS = ['Total', 'Subtotal', 'Balance', 'Debit tend'].freeze

  def create
    @grocery.update!({ receipt: params[:file] })
    match_results = find_matches(process_receipt)
    render json: render_matches(match_results)
  end

  private

  def render_matches(match_results)
    # Add new items and update existing items with the determined prices
    match_results.tap do |results|
      results[:matches].each do |match|
        if @grocery.items.where(name: match[:name]).length.zero?
          match.merge!(new: true)
        end
      end
    end
  end

  def find_matches(processed_receipt)
    processed_receipt.inject({ matches: [], total: 0 }) do |matches, capture|
      matches.tap do |acc|
        matcher = Matcher.new(capture.first.strip.downcase.capitalize)

        # There is a special case for matches to the total price
        if match = matcher.find_match(TOTAL_KEYWORDS)
          # Multiple matches for a total keyword favor the largest value
          acc[:total] = [capture[1].to_f, acc[:total]].max
        elsif match = matcher.find_match(@grocery.items.pluck(:name)) || matcher.find_match(Item.all.pluck(:name))
          # Aggregate duplicate items together
          aggregate_match = acc[:matches].detect { |existing_match| existing_match[:name] == match.result }
          if aggregate_match
            aggregate_match.merge!({
              price: aggregate_match[:price] += capture[1].to_f
            })
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
  end

  def process_receipt
    # Initialize Tesseract with English, only capital letters
    engine = Tesseract::Engine.new do |e|
      e.path = '/usr/local/share'
      e.language  = :en
      e.blacklist = ['|']
    end

    # Retrieve the cleaned file from Amazon and process its text
    file = open(@grocery.receipt.url)
    engine.text_for(file.path).strip.split("\n")
      .map { |line| line.match(/((?:[A-za-z]+\s)+).*?(\d*\.\d+)/) }
      .compact.map(&:captures)
  end
end
