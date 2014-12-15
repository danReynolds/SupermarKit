class Item < ActiveRecord::Base
	belongs_to :grocery

  scope :search, ->(q) { where('NAME LIKE :name OR ID LIKE :name', name: "%#{q}%") }
end