class GroceryPayment < ActiveRecord::Base
  belongs_to :user
  belongs_to :grocery
  validates_uniqueness_of :grocery_id, scope: :user_id
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_cents
end
