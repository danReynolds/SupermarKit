class Item < ActiveRecord::Base
	has_and_belongs_to_many :groceries
  
  monetize :price_cents,
    numericality: {
     greater_than_or_equal_to: 0
    }

  validate :name, presence: true, uniqueness: true

  scope :with_name, ->(q) { where('items.name LIKE ?', "%#{q}%").distinct }
end
