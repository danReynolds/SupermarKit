class Recipe < ActiveRecord::Base
  has_and_belongs_to_many :items
  has_and_belongs_to_many :groceries

  validates_uniqueness_of :external_id
end
