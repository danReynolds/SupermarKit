class GroceryStore < ActiveRecord::Base
  validates_presence_of :lat, :lng, :name

  acts_as_mappable
end
