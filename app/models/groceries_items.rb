class GroceriesItems < ActiveRecord::Base
  belongs_to :item
  belongs_to :grocery

	validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_cents

  # Determines the price for the item based on the most common non-zero
  # price at the closest grocery that has that item
  def localized_price
    grocery_store = grocery.grocery_store
    item_instances = GroceriesItems.where(item: item).where.not(price_cents: 0)
    price = 0

    # First try and calculate the price based on store proximity
    if grocery_store
      stores = GroceryStore.by_distance(origin: [grocery_store.lat.to_f, grocery_store.lng.to_f]).limit(10)

      stores.each do |store|
        prices = item_instances.where(grocery: store.groceries)

        if prices.length.nonzero?
          price = most_common_price(prices)
          break
        end
      end

    # If it was not in any nearby stores, then fall back on the overall most common price
    elsif price.zero? && item_instances.length.nonzero?
      price = most_common_price(item_instances)
    end

    price
  end

  def total_price
    quantity * price
  end

private

  def most_common_price(prices)
    prices.group(:price_cents).order('count_id DESC').count(:id).first.first
  end
end
