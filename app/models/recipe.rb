class Recipe < ApplicationRecord
  has_many :items_recipes, class_name: ItemsRecipes
  has_many :items, through: :items_recipes
  has_and_belongs_to_many :groceries

  validates :external_id, uniqueness: true, presence: true
  validates :name, uniqueness: true, presence: true
end
