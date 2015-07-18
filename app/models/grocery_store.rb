class GroceryStore < ActiveRecord::Base
  validates_presence_of :lat, :lng, :name

  has_many :groceries

  acts_as_mappable
end
