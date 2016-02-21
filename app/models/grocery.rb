class Grocery < ActiveRecord::Base
  has_many :groceries_items, class_name: GroceriesItems
  has_many :items, through: :groceries_items
  belongs_to :user_group
  belongs_to :grocery_store

  validates :name, presence: true

  def total
    total = items.inject(0) do |acc, i|
      acc += i.total_price(self)
    end
    Money.new(total).format(symbol: false).to_f
  end

  def finished?
    finished_at.present?
  end

  def format_items
    items.select(:id, :name, :description).map do |item|
      grocery_item = GroceriesItems.find_by_item_id_and_grocery_id(item.id, self.id)
      {
        id: item.id,
        name: item.name,
        description: item.description.to_s,
        grocery_item_id: grocery_item.id,
        quantity: grocery_item.quantity,
        quantity_formatted: "#{grocery_item.quantity.en.numwords} #{item.name.en.plural(grocery_item.quantity)}",
        price: grocery_item.price.dollars.to_s,
        price_formatted: grocery_item.price.format,
        total_price_formatted: grocery_item.total_price.format,
        path: item_path(item.id),
        requester: grocery_item.requester_id
      }
    end
  end
end
