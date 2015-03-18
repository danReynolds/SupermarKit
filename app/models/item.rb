class Item < ActiveRecord::Base

	has_many :groceries_items, class_name: GroceriesItems, inverse_of: :item
	has_many :groceries, through: :groceries_items

  accepts_nested_attributes_for :groceries_items

  validates :name, presence: true
	validates :price, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_cents

  scope :with_name, ->(q) { where('items.name LIKE ?', "%#{q}%").distinct }

	def quantity(grocery)
		groceries_items.find_by_grocery_id(grocery.id).quantity
	end

  def total_price(grocery)
    quantity(grocery) * price
  end
end
