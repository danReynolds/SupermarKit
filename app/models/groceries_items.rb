class GroceriesItems < ApplicationRecord
  include FractionalNumberToWords
  belongs_to :requester, class_name: User
  belongs_to :item
  belongs_to :grocery

	validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :grocery_id, scope: :item_id
  validates :units, inclusion: { in: UNIT_TYPES }, allow_blank: true
  monetize :price_cents

  CLOSEST_STORE_THRESHOLD = 10

  def units=(value)
    value = Unit.new(value).units if value.present?
    super(value)
  end

  def unit_quantity
    Unit.new("#{quantity.to_f} #{units}")
  end

  def estimated_price
    unit_prices = calculate_unit_prices(store_groceries_items)
    (unit_price_mode(unit_prices) * quantity.to_f).to_money
  end

  def price_or_estimated
    Money.new(price.zero? ? estimated_price : price)
  end

  def display_name
    quantity_words = frac_numwords(quantity)
    if units.present?
      "#{quantity_words} #{Unit.new(units).units.en.pluralize(quantity.ceil)} of #{item.name}"
    else
      "#{quantity_words} #{item.name.en.pluralize(quantity.ceil)}"
    end
  end

private

  # Finds all instances the item has been added to a grocery list with compatible units
  def store_groceries_items
    if store = grocery.grocery_store
      store_ids = GroceryStore.by_distance(
        origin: [store.lat.to_f, store.lng.to_f]
      ).limit(CLOSEST_STORE_THRESHOLD).where(name: store.name).map(&:id)
      groceries_items = GroceriesItems.joins(:grocery).where(
        groceries: { grocery_store_id: store_ids },
        item: item
      ).where.not(price_cents: 0)
    end

    if store.nil? || groceries_items.empty?
      groceries_items = GroceriesItems.where(item: item).where.not(price_cents: 0)
    end

    if units
      groceries_items.select { |item| item.units && item.units.to_unit.compatible?(units.to_unit) }
    else
      groceries_items.select { |item| item.units.nil? }
    end
  end

  # Determine the unit pricing for grocery items, converting to common unit if needed
  def calculate_unit_prices(groceries_items)
    groceries_items.map do |grocery_item|
      unit_quantity = units ? grocery_item.unit_quantity.convert_to(units).scalar : grocery_item.quantity.to_f
      grocery_item.price.to_f / unit_quantity
    end
  end

  def unit_price_mode(prices)
    return 0 if prices.empty?
    prices.inject(Hash.new(0)) do |price_frequency, price|
      price_frequency.tap { price_frequency[price] += 1 }
    end.to_a.sort_by(&:last).last.first
  end
end
