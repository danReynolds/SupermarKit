class Item < ActiveRecord::Base
  has_many :groceries_items, class_name: GroceriesItems, inverse_of: :item
  has_many :groceries, through: :groceries_items
  has_many :user_groups, through: :groceries

  validates :name, presence: true

  accepts_nested_attributes_for :groceries_items

  scope :with_name, ->(q) { where('items.name LIKE ?', "%#{q}%").distinct }

  def grocery_item(grocery)
    groceries_items.find_by_grocery_id(grocery.id)
  end

  def total_price_or_estimated(grocery)
    grocery_item(grocery).total_price_or_estimated
  end
end
