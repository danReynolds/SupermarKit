class GroceriesItems < ActiveRecord::Base
  belongs_to :item
  belongs_to :grocery

	validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :grocery_id, scope: :item_id
  monetize :price_cents

  # Determines the price for the item based on the most common non-zero
  # price at the closest grocery that has that item
  def localized_price
    grocery_store = grocery.grocery_store
    groceries_items = GroceriesItems.where(item: item).where.not(price_cents: 0)

    if grocery_store # First try and calculate the price based on store proximity
      stores = GroceryStore.by_distance(origin: [grocery_store.lat.to_f, grocery_store.lng.to_f]).limit(10)

      stores.each do |store|
        store_groceries_items = groceries_items.where(grocery: store.groceries)
        return most_common_price(store_groceries_items) if store_groceries_items.length.nonzero?
      end
    end

    # If it was not in any nearby stores, then fall back on the overall most common price
    most_common_price(groceries_items)
  end

  def total_price
    quantity * price
  end

private

  def most_common_price(groceries_items)
    return 0 if groceries_items.empty?
    groceries_items.group(:price_cents).order('count_id DESC').count(:id).first.first
  end
end
