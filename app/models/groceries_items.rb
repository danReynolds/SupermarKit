class GroceriesItems < ActiveRecord::Base
  belongs_to :item
  belongs_to :grocery

	validates :price, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_cents

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  # Determines the price for the item based on the most common non-zero
  # price at the closest grocery that has that item
  def localized_price
    grocery_store = grocery.grocery_store
    stores = GroceryStore.by_distance(origin: [grocery_store.lat.to_f, grocery_store.lng.to_f]).limit(10)
    item_instances = GroceriesItems.where(item: item)

    price = 0
    stores.each do |store|
      prices = item_instances.where(grocery: store.groceries)
               .where.not(price_cents: 0)

      if prices.length.nonzero?
        price = prices.group(:price_cents).order('count_id DESC').count(:id).first.first
        break
      end
    end

    price
  end
end
