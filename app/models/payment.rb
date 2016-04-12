class Payment < ActiveRecord::Base
  belongs_to :user
  belongs_to :grocery

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :grocery_id, scope: :item_id
  monetize :price_cents
end
