class Recipe < ApplicationRecord
  has_many :items_recipes, class_name: ItemsRecipes
  has_and_belongs_to_many :items, through: :items_recipes
  has_and_belongs_to_many :groceries

  validates_uniqueness_of :external_id
end
