class Item < ActiveRecord::Base
	belongs_to :grocery

  scope :with_name, ->(q) { where('items.name LIKE ?', "%#{q}%").distinct }
end
