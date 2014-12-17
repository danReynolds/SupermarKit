class Item < ActiveRecord::Base
	belongs_to :grocery

  scope :search, ->(q) { where('NAME LIKE :query OR ID LIKE :query', query: "%#{q}%") }
end
