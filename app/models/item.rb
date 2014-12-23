class Item < ActiveRecord::Base
	has_and_belongs_to_many :groceries

  scope :with_name, ->(q) { where('items.name LIKE ?', "%#{q}%").distinct }
end
