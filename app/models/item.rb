class Item < ActiveRecord::Base
	has_and_belongs_to_many :groceries
  
  validates :name, presence: true, uniqueness: true
  monetize :price_cents

  scope :with_name, ->(q) { where('items.name LIKE ?', "%#{q}%").distinct }
end
