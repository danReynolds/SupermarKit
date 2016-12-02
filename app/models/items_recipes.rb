class ItemsRecipes < ApplicationRecord
  belongs_to :item
  belongs_to :recipe

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :recipe_id, scope: :item_id
  validates :units, inclusion: { in: UNIT_TYPES }, allow_blank: true
end
