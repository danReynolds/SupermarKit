class Payment < ActiveRecord::Base
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_cents
end
