class GroceryStore < ApplicationRecord
  validates_presence_of :lat, :lng, :name, :place_id

  has_many :groceries
  has_many :groceries_items, through: :groceries

  acts_as_mappable
end
