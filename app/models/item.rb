class Item < ActiveRecord::Base
	has_and_belongs_to_many :groceries
  
  validates :name, presence: true, uniqueness: true
  monetize :price_cents,
    numericality: {
     greater_than_or_equal_to: 0
    }

  scope :with_name, ->(q) { where('items.name LIKE ?', "%#{q}%").distinct }
end
