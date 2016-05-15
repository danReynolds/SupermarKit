class Grocery < ActiveRecord::Base
  has_many :groceries_items, class_name: GroceriesItems
  has_many :payments
  has_many :items, through: :groceries_items
  has_and_belongs_to_many :recipes
  belongs_to :user_group
  belongs_to :grocery_store

  validates :name, presence: true

  def total_price_or_estimated
    items.inject(Money.new(0)) do |acc, i|
      acc += i.total_price_or_estimated(self)
    end
  end

  def items_without_recipes
    items.includes(:recipes).where(recipes: { id: nil })
  end

  def finished?
    finished_at.present?
  end
end
