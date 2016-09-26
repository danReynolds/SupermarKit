class GroceriesItems < ActiveRecord::Base
  belongs_to :requester, class_name: User
  belongs_to :item
  belongs_to :grocery

	validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :grocery_id, scope: :item_id
  monetize :price_cents

  CLOSEST_STORE_THRESHOLD = 10

  validates :units, inclusion: { in: UNIT_TYPES }

  # Determines the price for the grocery item based on the most common non-zero
  # price at the closest grocery that has that item
  def estimated_price
    grocery_store = grocery.grocery_store
    groceries_items = GroceriesItems.where(item: item).where.not(price_cents: 0)

    # Calculate the price by looking at the price at each of the closest stores with that name
    if grocery_store
      stores = GroceryStore.by_distance(origin: [grocery_store.lat.to_f, grocery_store.lng.to_f])
        .limit(CLOSEST_STORE_THRESHOLD)
        .where(name: grocery_store.name)

      stores.each do |store|
        store_groceries_items = groceries_items.where(grocery: store.groceries)
        return most_common_price(store_groceries_items) if store_groceries_items.length.nonzero?
      end
    end

    # Fallback on the overall most common price of all stores
    most_common_price(groceries_items)
  end

  def total_price_or_estimated
    quantity * price_or_estimated
  end

  def price_or_estimated
    Money.new(price.nonzero? ? price : estimated_price)
  end

  def display_name
    quantity_display = quantity.en.numwords
    if units
      unit = Unit.new(units).units
      name = "#{quantity_display} #{unit} of #{item.name}"
    else
      name = "#{quantity.en.numwords} #{item.name.en.plural(quantity)}"
    end
  end

private

  def most_common_price(groceries_items)
    return 0 if groceries_items.empty?
    Money.new(groceries_items.group(:price_cents).order('count_id DESC').count(:id).first.first)
  end
end
