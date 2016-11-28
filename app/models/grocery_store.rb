class GroceryStore < ApplicationRecord
  validates_presence_of :lat, :lng, :name, :place_id

  has_many :groceries

  acts_as_mappable
end
